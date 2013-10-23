//
//  PIDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIDelegate.h"

static NSString * const kLoginHelper = @"com.aapps.PILaunchAtLogin";


@implementation PIDelegate
@synthesize piBar;


//-------------------------------------------
//  Delegate Methods
//-------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSError  *error = nil;
    
    if(![JobBlesser blessHelperWithLabel:kHelperName
                               andPrompt:@"In order to use the SMC Printers"
                                   error:&error]){
        NSLog(@"Somthing went wrong");
        [PIPannelCotroller showErrorAlert:error
                           onWindow:nil
                       withSelector:@selector(setupDidEndWithTerminalError:)];
    }
    
    piBar = [[PIStatusBar alloc]initPrinterMenu];
    [piBar RefreshPrinters];
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

//-------------------------------------------
//  Menu Controller
//-------------------------------------------


-(void)managePrinter:(id)sender{
    NSMenuItem* pmi = sender;
    NSInteger pix = ([piBar.statusMenu indexOfItem:pmi]-2);
    NSDictionary* printer = [piBar.printerList objectAtIndex:pix];
    
    [pmi setState:pmi.state ? NSOffState : NSOnState];
    if (pmi.state){
        //NSLog(@"adding printer %@",[printer objectForKey:@"description"]);
        [PINSXPC addPrinter:printer];
    }else{
        //NSLog(@"removing printer %@",[printer objectForKey:@"description"]);
        [PINSXPC removePrinter:printer];
    }
}

-(void)quitNow{
    [NSApp terminate:self];
}

-(void)configure{
    [self.defaultsSetButton performClick:self];
}


@end
