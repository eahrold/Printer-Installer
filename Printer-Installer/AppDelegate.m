//
//  AppDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
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
    
    AppPannel* ap = [AppPannel new];
    [ap startDefaultsPanel:@"hellp"];
    
    if(_error){
        [AppPannel showErrorAlert:_error
                           onWindow:self.window
                       withSelector:@selector(setupDidEndWithTerminalError:)];
    }
        
    // Insert code here to initialize your application
    NSError  *error = nil;
    
    if(![JobBlesser blessHelperWithLabel:kHelperName
                               andPrompt:@"In order to User the SMC Printers"
                                   error:&error]){
        NSLog(@"Somthing went wrong");
        [AppPannel showErrorAlert:error
                           onWindow:self.window
                       withSelector:@selector(setupDidEndWithTerminalError:)];
        
    
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [AppNSXPC tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

@end
