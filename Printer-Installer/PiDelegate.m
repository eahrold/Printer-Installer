//
//  PIDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIDelegate.h"

#import <ServiceManagement/ServiceManagement.h>
#import <Sparkle/SUUpdater.h>
#import "SMJobBlesser.h"
#import "PINSXPC.h"
#import "PIError.h"

static NSString* kShowBonjourPrinters = @"ShowBonjourPrinters";


@implementation PIDelegate{
}

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
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{
                                                             kShowBonjourPrinters:@NO,                                           }];
    
    if(![JobBlesser blessHelperWithLabel:kHelperName
                           andPrompt:@"In order to add managed Printers"
                               error:&error]){
    
        if(error){
            [[NSApplication sharedApplication]activateIgnoringOtherApps:YES];
            [PIError presentError:error
                         delegate:self
               didPresentSelector:@selector(setupDidEndWithTerminalError:)];
             }
    }
    
    if([[SUUpdater sharedUpdater]feedURL]){
         [[SUUpdater sharedUpdater]checkForUpdatesInBackground];
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
}

-(void)showAboutPanel{
    [[NSApplication sharedApplication]activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

- (void)setupDidEndWithTerminalError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
    [NSApp terminate:self];
}

-(void)setupDidRemoveHelperTool:(NSAlert *)alert{
    NSLog(@"Helper Tools Removed");
    [NSApp terminate:self];
}

@end
