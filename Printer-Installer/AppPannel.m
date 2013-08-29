//
//  AppProgress.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppPannel.h"

@implementation AppPannel

//-------------------------------------------
//  Progress Panel and Alert
//-------------------------------------------

- (void)startDefaultsPanel:(NSString*)message{
    /* Display a progress panel as a sheet */
    [self.defaultsOKButton setEnabled:YES];
    [NSApp beginSheet:self.defaultsPanel
       modalForWindow:[[NSApplication sharedApplication] mainWindow]
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
}


+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:window
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

+ (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication]mainWindow]
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:window                                               modalDelegate:self
                                              didEndSelector:selector
                                                 contextInfo:nil];
}


+ (void)setupDidEndWithTerminalError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
    [NSApp terminate:self];
}
@end
