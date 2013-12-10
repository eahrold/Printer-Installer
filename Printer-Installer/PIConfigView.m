//
//  PIConfigView.m
//  Printer-Installer
//
//  Created by Eldon on 12/10/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIConfigView.h"

@interface PIConfigView ()

@end

@implementation PIConfigView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.panelMessage = @"Please enter the URL for the managed printers:";
    }
    return self;
}

-(IBAction)cancel:(id)sender{
    [_delegate cancelConfigView];
}
-(IBAction)configure:(id)sender{
    [_delegate refreshPrinterList];
}

-(IBAction)launchAtLoginChecked:(id)sender{
    NSButton* button = sender;
    if(![_delegate installLoginItem:button.state]){
        button.state = button.state ? YES:NO;
    };
}


@end
