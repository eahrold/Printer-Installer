//
//  PIProgress.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIConfigSheet.h"

@interface PIConfigSheet ()

@end

static NSString * const kLoginHelper = @"edu.loyno.smc.Printer-Installer.loginlaunch";

@implementation PIConfigSheet
@synthesize delegate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.panelMessage = @"Please enter the URL for the managed printers:";
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)cancel:(id)sender{
    [delegate cancelConfigSheet];
}
-(IBAction)configure:(id)sender{
    [delegate setPrinterList];
}

-(IBAction)launchAtLoginChecked:(id)sender{
    NSButton* button = sender;
    if(![delegate installLoginItem:button.state]){
        if(button.state)button.state=NO; else button.state=YES;
    };
    
}



@end
