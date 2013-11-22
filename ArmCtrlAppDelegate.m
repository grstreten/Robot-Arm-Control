//
//  ArmCtrlAppDelegate.m
//  ArmCtrl
//
//  Created by Paul Law on 04/03/2011.
//

#import "ArmCtrlAppDelegate.h"
#import "ArmCommand.h"

@implementation ArmCtrlAppDelegate

@synthesize window, byte0, byte1, byte2, lightStatus, grabberStatus, wristStatus, elbowStatus, shoulderStatus, baseStatus;
@synthesize segBase, segShoulder, segElbow, segWrist, segGrip, segLight;

unsigned char command[3];

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	CommandArm(command);
    command[0] = 0;
	command[1] = 0;
	command[2] = 0;
	[self updateDisplay];
    [lightStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [grabberStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [wristStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [elbowStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [shoulderStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [baseStatus setStringValue:[NSString stringWithFormat:@"Off"]];
	[segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
}

- (IBAction)segControlClicked:(id)sender {
	
	if (sender == segLight) {
		command[2] = ([sender selectedSegment] == 1) ? 0 : 1;	// Light
	}
	else if (sender == segBase) {
		switch ([sender selectedSegment]) {
			case 0: command[1] = 2; break;		// Base CW
			case 1: command[1] = 0; break;
			case 2: command[1] = 1; break;		// Base CCW
		}
	}
	else if (sender == segShoulder) {
		command[0] &= 0x3F;		// Turn off bit 7+8
		switch ([sender selectedSegment]) {
			case 0: command[0] |= 0x40; break;		// Shoulder Up
			case 2: command[0] |= 0x80; break;		// Shoulder Down
		}
	}
	else if (sender == segElbow) {
		command[0] &= 0xCF;		// Turn off bit 5+6
		switch ([sender selectedSegment]) {
			case 0: command[0] |= 0x10; break;		// Elbow Up
			case 2: command[0] |= 0x20; break;		// Elbow Down
		}
	}
	else if (sender == segWrist) {
		command[0] &= 0xF3;		// Turn off bit 3+4
		switch ([sender selectedSegment]) {
			case 0: command[0] |= 0x04; break;		// Wrist Up
			case 2: command[0] |= 0x08; break;		// Wrist Down
		}
	}
	else if (sender == segGrip) {
		command[0] &= 0xFC;		// Turn off bit 1+2
		switch ([sender selectedSegment]) {
			case 0: command[0] |= 0x02; break;		// Grip Open
			case 2: command[0] |= 0x01; break;		// Grip Close
		}
	}
	CommandArm(command);
	[self updateDisplay];
}

- (IBAction)allStopClicked:(id)sender {
	command[0] = 0; command[1] = 0;
	CommandArm(command);
	[segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [grabberStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [wristStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [elbowStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [shoulderStatus setStringValue:[NSString stringWithFormat:@"Off"]];
    [baseStatus setStringValue:[NSString stringWithFormat:@"Off"]];
}

- (IBAction)right:(id)sender { //actually Left
    command[1] = 2;
	CommandArm(command);
    [segBase setSelectedSegment:0];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [baseStatus setStringValue:[NSString stringWithFormat:@"Left"]];
}

- (IBAction)left:(id)sender { //actually Right
    command[1] = 1;
	CommandArm(command);
    [segBase setSelectedSegment:2];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [baseStatus setStringValue:[NSString stringWithFormat:@"Right"]];
}

- (IBAction)upShoulder:(id)sender {
    command[0] |= 0x40;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:0];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [shoulderStatus setStringValue:[NSString stringWithFormat:@"Up"]];
}

- (IBAction)downShoulder:(id)sender {
    command[0] |= 0x80;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:2];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [shoulderStatus setStringValue:[NSString stringWithFormat:@"Down"]];
}

- (IBAction)upElbow:(id)sender {
    command[0] |= 0x10;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:0];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [elbowStatus setStringValue:[NSString stringWithFormat:@"Up"]];
}

- (IBAction)downElbow:(id)sender {
    command[0] |= 0x20;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:2];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [elbowStatus setStringValue:[NSString stringWithFormat:@"Down"]];
}

- (IBAction)upWrist:(id)sender {
    command[0] |= 0x04;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:0];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [wristStatus setStringValue:[NSString stringWithFormat:@"Up"]];
}

- (IBAction)downWrist:(id)sender {
    command[0] |= 0x08;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:2];
	[segGrip setSelectedSegment:1];
	[self updateDisplay];
    [wristStatus setStringValue:[NSString stringWithFormat:@"Down"]];
}

- (IBAction)open:(id)sender {
    command[0] |= 0x02;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:0];
	[self updateDisplay];
    [grabberStatus setStringValue:[NSString stringWithFormat:@"Opening"]];
}

- (IBAction)close:(id)sender {
    command[0] |= 0x01;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:2];
	[self updateDisplay];
    [grabberStatus setStringValue:[NSString stringWithFormat:@"Closing"]];
}

- (IBAction)lightOn:(id)sender {
    command[2] = 1;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
    [segLight setSelectedSegment:0];
	[self updateDisplay];
    [lightStatus setStringValue:[NSString stringWithFormat:@"On"]];
}

- (IBAction)lightOff:(id)sender {
    command[2] = 0;
	CommandArm(command);
    [segBase setSelectedSegment:1];
	[segShoulder setSelectedSegment:1];
	[segElbow setSelectedSegment:1];
	[segWrist setSelectedSegment:1];
	[segGrip setSelectedSegment:1];
    [segLight setSelectedSegment:1];
	[self updateDisplay];
    [lightStatus setStringValue:[NSString stringWithFormat:@"Off"]];    
}

- (IBAction)dance:(id)sender {

}

- (void)updateDisplay {
	[byte0 setStringValue:[NSString stringWithFormat:@"%02x",command[0]]];
	[byte1 setStringValue:[NSString stringWithFormat:@"%02x",command[1]]];
	[byte2 setStringValue:[NSString stringWithFormat:@"%02x",command[2]]];
}

@end
