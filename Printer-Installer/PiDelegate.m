//
//  PIDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIDelegate.h"

#import <Sparkle/SUUpdater.h>
#import <CDEvents/CDEvent.h>
#import <CDEvents/CDEvents.h>

#import <ServiceManagement/ServiceManagement.h>
#import <Sparkle/SUUpdater.h>
#import "AHLaunchCtl.h"
#import "PINSXPC.h"
#import "PIError.h"

static NSString* kPrintQuotaMonitor = @"PrintQuotaMonitor";
static NSString* kShowBonjourPrinters = @"ShowBonjourPrinters";


@implementation PIDelegate{
    CDEvents *_events;
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
                                                             kPrintQuotaMonitor:@YES,
                                                             kShowBonjourPrinters:@NO,
                                                             }];
    
    if(![AHLaunchCtl installHelper:kHelperName prompt:@"In order to add managed Printers" error:&error ])
    {
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
    
    [self watchCupsDir:[[NSUserDefaults standardUserDefaults] boolForKey:kPrintQuotaMonitor]];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kPrintQuotaMonitor
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
    [self quitPaperCut];
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


#pragma mark - Print Quota Management
-(void)openPaperCut{
    NSString* launchApp = [NSString stringWithFormat:@"%@/PCClient.app",[[NSBundle mainBundle]resourcePath]];
    NSString* bundleID = @"biz.papercut.pcng.client";
    BOOL alreayRunning = NO;
    if ([[NSWorkspace sharedWorkspace] respondsToSelector:@selector(runningApplications)])
        for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
            if ([bundleID isEqualToString:[app bundleIdentifier]])
                alreayRunning = YES;
    
    if(!alreayRunning)
        [[NSWorkspace sharedWorkspace] launchApplication:launchApp];
}

-(void)quitPaperCut{
    NSString* bundleID = @"biz.papercut.pcng.client";
    if ([[NSWorkspace sharedWorkspace] respondsToSelector:@selector(runningApplications)])
        for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
            if ([bundleID isEqualToString:[app bundleIdentifier]])
                [app terminate];
}

-(void)watchCupsDir:(BOOL)watch{
    if(watch){
        NSURL* cups =[NSURL URLWithString:@"/var/spool/cups/"];
        _events = [[CDEvents alloc]initWithURLs:@[cups] block:
                   ^(CDEvents *watcher, CDEvent *event) {
                       [self openPaperCut];
                   } onRunLoop:[NSRunLoop currentRunLoop]];
    }else{
        _events = nil;
    }
}


-(void)dealloc{
    [[NSUserDefaults standardUserDefaults]removeObserver:self forKeyPath:kPrintQuotaMonitor];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:kPrintQuotaMonitor]){
        [self watchCupsDir:[[change valueForKey:@"new"] boolValue]];
    }
}
@end
