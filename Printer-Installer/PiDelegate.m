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

@synthesize window, piBar;



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
    piBar = [[PIStatusBar alloc]initPrinterMenu];
    [piBar RefreshPrinters];
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [PINSXPC tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return NO;
}

-(void)managePrinter:(id)sender{
    NSMenuItem* pmi = sender;
    NSInteger pix = [piBar.statusMenu indexOfItem:pmi];
    NSDictionary* printer = [piBar.printerList objectAtIndex:pix];
    
    [pmi setState:pmi.state ? NSOffState : NSOnState];
    if (pmi.state){
        NSLog(@"adding printer");
        [PINSXPC addPrinter:printer];
    }else{
        NSLog(@"removing printer");
        [PINSXPC removePrinter:printer];
    }
}

-(void)quitNow{
    [NSApp terminate:self];
}

-(void)configure{
    [self startDefaultsPanel:nil];
}

- (IBAction)startDefaultsPanel:(id)sender{    
    if(sender == nil){
        self.panelMessage = @"Please enter the web address for the printers";
    }
    
    NSString* sn = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];
    if(sn){
        _defaultsServerName.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];
    }
    
    [NSApp beginSheet:_defaultsPanel
       modalForWindow:nil
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:NULL];
}

- (IBAction)endDefaultsPanel:(id)sender{
    [NSApp endSheet:self.defaultsPanel];
    NSUserDefaults* setDefaults = [NSUserDefaults standardUserDefaults];
    if(![_defaultsServerName.stringValue isEqualToString:@""]){
        [setDefaults setObject:_defaultsServerName.stringValue forKey:@"server"];
        [setDefaults synchronize];
        [piBar RefreshPrinters];
        if(piBar.printerList.count == 0){
            [self.defaultsQuitButton setHidden:FALSE];
            self.panelMessage = @"The URL you entered may not be correct, please try again:";
            [self startDefaultsPanel:self];
        }else{
            [self.defaultsPanel close];
        }
    }
}

- (IBAction)cancel:(id)sender{
    [NSApp endSheet:self.defaultsPanel];
    [self.defaultsPanel close];
}


@end
