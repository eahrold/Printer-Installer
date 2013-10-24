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

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.panelMessage = @"Please enter the url";
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//-------------------------------------------
//  Configure Sheet
//-------------------------------------------


-(IBAction)setButtonPressed:(id)sender{
    PIDelegate* delegate = [NSApp delegate];
    
    if(delegate.piBar.printerList.count == 0){
        self.panelMessage = @"The URL you entered may not be correct, please try again:";
        [self.defaultsCancelButton setHidden:NO];
    }else{
        [self.window close];
        delegate.configSheet = nil;
    }
}

-(IBAction)cancelButtonPressed:(id)sender{
    [self.window close];
    [[NSApp delegate] setConfigSheet:nil];
}

-(IBAction)launchAtLoginChecked:(id)sender{
    NSButton* btn = sender;
    [JobBlesser setLaunchOnLogin:btn.state withLabel:kLoginHelper];
}


//-------------------------------------------
//  Progress Panel and Alert
//-------------------------------------------

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
