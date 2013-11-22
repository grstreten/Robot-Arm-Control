/*
 *  ArmCommand.c
 *  ArmCtrl
 *
 *  Created by Paul Law on 04/03/2011.
 *  Improved by George Streten (@GStreten). Code Available at GitHub.
 */

#include "ArmCommand.h"


#include <CoreFoundation/CoreFoundation.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/usb/IOUSBLib.h>
#include <IOKit/usb/USBSpec.h>
#include <IOKit/IOCFPlugIn.h>
#include <mach/mach_port.h>

#define ARM_VENDOR       0x1267
#define ARM_PRODUCT      0
#define CMD_DATALEN      3


static io_iterator_t			gDeviceAddedIter;
static io_iterator_t			gDeviceRemovedIter;
static IONotificationPortRef    gNotifyPort;
unsigned char			cmd[3];

IOReturn SendCommand(IOUSBDeviceInterface **dev)
{
	IOUSBDevRequest	request;
	
	fprintf(stderr, "Sending %02X %02X %02X\n",
            (int)cmd[0],
            (int)cmd[1],
            (int)cmd[2]
			);
	
	request.bmRequestType = USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBDevice);
    request.bRequest = 0x06;
    request.wValue = 0x100;
    request.wIndex = 0;
    request.wLength = CMD_DATALEN;
    request.pData = cmd;
	
    return (*dev)->DeviceRequest(dev, &request);
}


void DeviceAdded(void *refCon, io_iterator_t iterator) 
{
	kern_return_t			kr;
	io_service_t			usbDevice;
	IOCFPlugInInterface		**plugInInterface = NULL;
	IOUSBDeviceInterface	**device = NULL;
	HRESULT					result;
	SInt32					score;
	UInt16					vendor;
	UInt16					product;
	
	while (usbDevice = IOIteratorNext(iterator)) 
	{
		// Create an intermediate plug-in
		kr = IOCreatePlugInInterfaceForService(usbDevice,
											   kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID,
											   &plugInInterface, &score);
		// Don't need the device object after intermediate plug-in is created
		kr = IOObjectRelease(usbDevice);
		if ((kIOReturnSuccess != kr) || !plugInInterface)
		{
			printf("Unable to create a plug-in (%08x)\n",kr);
			continue;
		}
		
		// Now create the device interface
		result = (*plugInInterface)->QueryInterface(plugInInterface,
													CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
													(LPVOID *)&device);
		// Don't need the intermediate plug-in after device interface is created
		(*plugInInterface)->Release(plugInInterface);
		
		if (result || !device)
		{
			printf("Couldn't create a device interface (%08x)\n",
				   (int) result);
			continue;
		}
		
		// Check device is what we expected
		kr = (*device)->GetDeviceVendor(device, &vendor);
		kr = (*device)->GetDeviceProduct(device, &product);
		if ((vendor != ARM_VENDOR) || (product != ARM_PRODUCT))
		{
			printf("Found unwanted device (vendor = %d, product = %d)\n",
				   vendor, product);
			(void)(*device)->Release(device);
			continue;
		}
		
		// Open the device to change its state
		kr = (*device)->USBDeviceOpen(device);
		if (kr != kIOReturnSuccess)
		{
			printf("Unable to open device: %08x\n", kr);
			(void) (*device)->Release(device);
			continue;
		}
		
		// Get the interfaces
		kr = SendCommand(device);
		if (kr != kIOReturnSuccess)
		{
			printf("Unable to command device: %08x\n",kr);
			(*device)->USBDeviceClose(device);
			(*device)->Release(device);
			continue;
		}
		
		// Close device and release object
		kr = (*device)->USBDeviceClose(device);
		kr = (*device)->Release(device);
	}
}

void DeviceRemoved(void *refCon, io_iterator_t iterator)
{
	kern_return_t	kr;
	io_service_t	object;
	
	while (object = IOIteratorNext(iterator))
	{
		kr = IOObjectRelease(object);
		if (kr != kIOReturnSuccess)
		{
			printf("Couldn't release raw device object: %08x\n",kr);
			continue;
		}
	}
}

void CommandArm (unsigned char cmds[]) {
	
	cmd[0] = cmds[0];
	cmd[1] = cmds[1];
	cmd[2] = cmds[2];
	
    // Create a master port for communication with the I/O Kit
	mach_port_t		masterPort;
	kern_return_t	kr;
	kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (kr || !masterPort)
	{
		printf("Error: Couldn't create a master I/O Kit port(%08x)\n", kr);
		return;
	}
	
	// Set up matching dictionary for class IOUSBDevice and its subclasses
	CFMutableDictionaryRef matchingDict;
	matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
	if (!matchingDict)
	{
		printf("Couldn't create a USB matching dictionary\n");
		mach_port_deallocate(mach_task_self(), masterPort);
		return;
	}
	
	// Add the vendor and product IDs to the matching dictionary.
	// This is the second key in the table of device-matching kes of the
	// USB Common Class Specification
	SInt32	usbVendor	= ARM_VENDOR;
	SInt32	usbProduct	= ARM_PRODUCT;
	CFDictionarySetValue(matchingDict, CFSTR(kUSBVendorName),
						 CFNumberCreate(kCFAllocatorDefault,
										kCFNumberSInt32Type, &usbVendor));
	CFDictionarySetValue(matchingDict, CFSTR(kUSBProductName),
						 CFNumberCreate(kCFAllocatorDefault,
										kCFNumberSInt32Type, &usbProduct));
	
	
	//To set up asynchronous notifications, create a notification port and
    //add its run loop event source to the program’s run loop
	CFRunLoopSourceRef      runLoopSource;
    gNotifyPort = IONotificationPortCreate(masterPort);
    runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource,
					   kCFRunLoopDefaultMode);
	
	//Retain additional dictionary references because each call to
    //IOServiceAddMatchingNotification consumes one reference
    matchingDict = (CFMutableDictionaryRef) CFRetain(matchingDict);
    matchingDict = (CFMutableDictionaryRef) CFRetain(matchingDict);
    
	//Now set up two notifications: one to be called when a raw device
    //is first matched by the I/O Kit and another to be called when the
    //device is terminated
    //Notification of first match:
    kr = IOServiceAddMatchingNotification(gNotifyPort,
										  kIOFirstMatchNotification, matchingDict,
										  DeviceAdded, NULL, &gDeviceAddedIter);
	// Iterate over set of matching devices to access already-present devices
	DeviceAdded(NULL, gDeviceAddedIter);
	
	//Notification of termination:
    kr = IOServiceAddMatchingNotification(gNotifyPort,
										  kIOTerminatedNotification, matchingDict,
										  DeviceRemoved, NULL, &gDeviceRemovedIter);
	// Iterate over set of matching devices to release each one
	DeviceRemoved(NULL, gDeviceRemovedIter);
	
	// Finished with master port
	mach_port_deallocate(mach_task_self(), masterPort);
	masterPort = 0;	
}

