//
//  PIDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIDelegate.h"

#import <Sparkle/SUUpdater.h>
#import <ServiceManagement/ServiceManagement.h>
#import "SMJobBlesser.h"
#import "PINSXPC.h"
#import "PIError.h"

@implementation PIDelegate

//-------------------------------------------
//  Delegate Methods
//-------------------------------------------

-(void)applicationWillFinishLaunching:(NSNotification *)notification{


}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
NSLog(@"%@", replyEvent);

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError  *error = nil;
    
    if(![JobBlesser blessHelperWithLabel:kHelperName
                           andPrompt:@"In order to add managed Printers"
                               error:&error]){
    
        if(error){
            [NSApp presentError:error modalForWindow:NULL delegate:self
             didPresentSelector:@selector(setupDidEndWithTerminalError:) contextInfo:nil];
        }
    }
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"managed"]){
        [PINSXPC installGlobalLoginItem];
    }
    
    if([[SUUpdater sharedUpdater]feedURL]){
         [[SUUpdater sharedUpdater]checkForUpdatesInBackground];
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

- (void)setupDidEndWithTerminalError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
    [NSApp terminate:self];
}

@end
