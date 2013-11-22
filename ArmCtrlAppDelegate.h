//
//  ArmCtrlAppDelegate.h
//  ArmCtrl
//
//  Created by Paul Law on 04/03/2011.
//  Improved by George Streten (@GStreten). Code Available at GitHub.
//

#import <Cocoa/Cocoa.h>

@interface ArmCtrlAppDelegate : NSObject {
    NSWindow *window;
	
	NSTextField *byte0;
	NSTextField *byte1;
	NSTextField *byte2;
	
	NSSegmentedControl *segBase;
	NSSegmentedControl *segShoulder;
	NSSegmentedControl *segElbow;
	NSSegmentedControl *segWrist;
	NSSegmentedControl *segGrip;
	NSSegmentedControl *segLight;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *byte0;
@property (assign) IBOutlet NSTextField *byte1;
@property (assign) IBOutlet NSTextField *byte2;
@property (assign) IBOutlet NSSegmentedControl *segBase;
@property (assign) IBOutlet NSSegmentedControl *segShoulder;
@property (assign) IBOutlet NSSegmentedControl *segElbow;
@property (assign) IBOutlet NSSegmentedControl *segWrist;
@property (assign) IBOutlet NSSegmentedControl *segGrip;
@property (assign) IBOutlet NSSegmentedControl *segLight;
@property (assign) IBOutlet NSTextField *lightStatus;
@property (assign) IBOutlet NSTextField *grabberStatus;
@property (assign) IBOutlet NSTextField *wristStatus;
@property (assign) IBOutlet NSTextField *elbowStatus;
@property (assign) IBOutlet NSTextField *shoulderStatus;
@property (assign) IBOutlet NSTextField *baseStatus;

- (IBAction)segControlClicked:(id)sender;
- (IBAction)allStopClicked:(id)sender;

- (void)updateDisplay;

@end
