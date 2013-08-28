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
        
    if(_error){
        [AppProgress showErrorAlert:_error
                           onWindow:self.window
                       withSelector:@selector(setupDidEndWithTerminalError:)];
    }
    
    //[AppTable new];
    
    // Insert code here to initialize your application
    NSString *prompt = @"In order to User the SMC Printers";
    NSError  *error = nil;
    
    if(![JobBlesser blessHelperWithLabel:kHelperName andPrompt:prompt error:&error]){
        NSLog(@"Somthing went wrong");
        [AppProgress showErrorAlert:_error
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
