//
//  PIApplication.m
//  Printer-Installer
//
//  Created by Eldon on 10/24/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//
// thanks http://cocoa.flyingmac.com/2010/07/cut-copy-and-paste-in-lsuielement-applications/
//

#import "PIApplication.h"

@implementation PIApplication

- (void) sendEvent:(NSEvent *)event {
	if ([event type] == NSKeyDown) {
		if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
			if ([[event charactersIgnoringModifiers] isEqualToString:@"x"]) {
				if ([self sendAction:@selector(cut:) to:nil from:self])
					return;
			}
			else if ([[event charactersIgnoringModifiers] isEqualToString:@"c"]) {
				if ([self sendAction:@selector(copy:) to:nil from:self])
					return;
			}
			else if ([[event charactersIgnoringModifiers] isEqualToString:@"v"]) {
				if ([self sendAction:@selector(paste:) to:nil from:self])
					return;
			}
			else if ([[event charactersIgnoringModifiers] isEqualToString:@"z"]) {
				if ([self sendAction:@selector(undo:) to:nil from:self])
					return;
			}
			else if ([[event charactersIgnoringModifiers] isEqualToString:@"a"]) {
				if ([self sendAction:@selector(selectAll:) to:nil from:self])
					return;
			}
		}
		else if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) ==
                 (NSCommandKeyMask | NSShiftKeyMask)) {
			if ([[event charactersIgnoringModifiers] isEqualToString:@"Z"]) {
				if ([self sendAction:@selector(redo:) to:nil from:self])
					return;
			}
		}
	}
	[super sendEvent:event];
}

@end
