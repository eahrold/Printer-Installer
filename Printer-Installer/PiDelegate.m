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


@end
