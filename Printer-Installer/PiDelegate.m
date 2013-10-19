//
//  PIDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIDelegate.h"


@implementation PIDelegate
NSError* _error;

@synthesize window;



//-------------------------------------------
//  Set Up Arrays
//-------------------------------------------


-(void)setDefaults{
    NSUserDefaults* setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setObject:printerList forKey:@"printerList"];
    [setDefaults synchronize];
}



//-------------------------------------------
//  Delegate Methods
//-------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{        
    if(_error){
        [PIPannel showErrorAlert:_error
                           onWindow:window
                       withSelector:@selector(setupDidEndWithTerminalError:)];
    }
        
    // Insert code here to initialize your application
    NSError  *error = nil;
    
    if(![JobBlesser blessHelperWithLabel:kHelperName
                               andPrompt:@"In order to use the SMC Printers"
                                   error:&error]){
        NSLog(@"Somthing went wrong");
        [PIPannel showErrorAlert:error
                           onWindow:window
                       withSelector:@selector(setupDidEndWithTerminalError:)];
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

@end
