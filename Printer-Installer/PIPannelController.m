//
//  PIProgress.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIPannelController.h"

@interface PIPannelCotroller ()

@end

static NSString * const kLoginHelper = @"com.aapps.PILaunchAtLogin";

@implementation PIPannelCotroller
@synthesize configSheet = _configSheet;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//-------------------------------------------
//  Progress Panel and Alert
//-------------------------------------------

-(IBAction)openConfigSheet:(id)sender{
    self.panelMessage = @"Enter the URL for the printers:";
    if(!_configSheet){
        [NSBundle loadNibNamed:@"ConfigSheet" owner:self];
    }
    [NSApp beginSheet:self.configSheet
       modalForWindow:NULL
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:NULL];
}

-(IBAction)closeConfigSheet:(id)sender{
    NSButton* btn = sender;
    PIDelegate* delegate = [NSApp delegate];
    
    if([btn.title isEqualToString:@"Set"]){
        [delegate.piBar RefreshPrinters];
        if(delegate.piBar.printerList.count == 0){
            self.panelMessage = @"The URL you entered may not be correct, please try again:";
            [self.defaultsCancelButton setHidden:NO];
        }else{
            [NSApp endSheet:self.configSheet];
            [self.configSheet close];
            self.configSheet=nil;
        }
    }else{
        NSLog(@"Canceling");
        [NSApp endSheet:self.configSheet];
        [self.configSheet close];
        self.configSheet=nil;
    }
    
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)launchAtLoginChecked:(id)sender{
    NSButton* btn = sender;
    [JobBlesser setLaunchOnLogin:btn.state withLabel:kLoginHelper];
}


+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:window
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

+ (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication]mainWindow]
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

+ (void)showErrorAlert:(NSError *)error withSelector:(SEL)selector{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication]mainWindow]
                                               modalDelegate:self
                                              didEndSelector:selector
                                                 contextInfo:nil];
}


+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:window
                                               modalDelegate:self
                                              didEndSelector:selector
                                                 contextInfo:nil];
}


+ (void)setupDidEndWithTerminalError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
    [NSApp terminate:self];
}


@end
