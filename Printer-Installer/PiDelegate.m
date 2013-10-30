//
//  PIDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIDelegate.h"
#import <Sparkle/SUUpdater.h>

static NSString * const kLoginHelper = @"edu.loyno.smc.Printer-Installer.loginlaunch";


@implementation PIDelegate
@synthesize piBar,configSheet;


//-------------------------------------------
//  Delegate Methods
//-------------------------------------------

-(void)applicationWillFinishLaunching:(NSNotification *)notification{
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"SUFeedURLKey"]){
        [[SUUpdater sharedUpdater]checkForUpdatesInBackground];
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSError  *error = nil;
    
       if(![JobBlesser blessHelperWithLabel:kHelperName
                               andPrompt:@"In order to add managed Printers"
                                   error:&error]){
        NSLog(@"Somthing went wrong");
        [PIPannelCotroller showErrorAlert:error
                           onWindow:nil
                       withSelector:@selector(setupDidEndWithTerminalError:)];
    }
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"managed"]){
        [PINSXPC installGlobalLoginItem];
    }
}

-(void)awakeFromNib{
    piBar = [[PIStatusBar alloc]initPrinterMenu];

    [piBar RefreshPrinters];
    if(piBar.printerList.count == 0){
        [self configure];
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

//-------------------------------------------
//  PIStatusBar Controller
//-------------------------------------------

-(void)quitNow{
    [NSApp terminate:self];
}

-(void)configure{
    [NSApp activateIgnoringOtherApps:YES];
    if(!configSheet){
        configSheet = [[PIPannelCotroller alloc]initWithWindowNibName:@"ConfigSheet"];
    }
    [configSheet showWindow:nil];
}


@end
