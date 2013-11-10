//
//  PIController.m
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Sparkle/SUUpdater.h>
#import <Server/Server.h>

#import "PIController.h"
#import "PIDelegate.h"
#import "PINSXPC.h"

@implementation PIController{
    NSArray *printerList;
}

@synthesize piMenu;
@synthesize configSheet;

#pragma mark - setup
-(void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:piMenu];
    [statusItem setImage:[NSImage imageNamed:@"StatusBar"]];
    [statusItem setHighlightMode:YES];
    [piMenu setDelegate:self];
    [self setPrinterList];
}

#pragma mark -- Class Methods
-(void)setPrinterList{
    NSString* url = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"server"];
    
    Server* server = [[Server alloc]initWithQueue];
    server.URL = [NSURL URLWithString:url];
    
    [server getRequestReturningData:^(NSData *data) {
        NSDictionary *settings =[NSDictionary dictionaryFromData:data];

        printerList = [settings objectForKey:@"printerList"];
        if(printerList.count){
            [piMenu updateMenuItems];
            [self cancelConfigSheet];
        }else{
            configSheet.panelMessage = @"There are no printers shared with that group at this time:";
        }

        NSString* feedURL = [settings objectForKey:@"updateServer"];

        if([Server checkURL:feedURL]){
            [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
        }else{
            feedURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SUFeedURL"];
            [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
        }
    }withError:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        
        configSheet.panelMessage = @"The URL you entered may not be correct, please try again:";
        [configSheet.defaultsCancelButton setHidden:NO];
        [self performSelectorOnMainThread:@selector(configure:) withObject:self waitUntilDone:NO];

    }];
}


#pragma mark -- IBActions
-(IBAction)checkForUpdates:(id)sender{
    [[SUUpdater sharedUpdater]checkForUpdates:self];
}

-(IBAction)quitNow:(id)sender{
    [NSApp terminate:self];
}

-(IBAction)configure:(id)sender{
    if(!configSheet){
        configSheet = [[PIPannelCotroller alloc]initWithWindowNibName:@"ConfigSheet"];
        [configSheet setDelegate:self];
    }
    [configSheet showWindow:self];
}


#pragma mark - config sheet delegate methods
-(void)cancelConfigSheet{
    [configSheet close];
    configSheet = nil;
}

-(void)setConfiguration{
    [self setPrinterList];
}


#pragma mark - menu delegate methods
-(NSArray*)printersInPrinterList:(PIMenu *)piMenu{
    return printerList;
}

#pragma mark - internal methods
-(void)managePrinter:(id)sender{
    NSMenuItem* pmi = sender;
    NSInteger pix = ([piMenu indexOfItem:pmi]-2);
    NSDictionary* printer = [printerList objectAtIndex:pix];
    
    if (!pmi.state){
        [PINSXPC addPrinter:printer menuItem:pmi];
    }else{
        [PINSXPC removePrinter:printer menuItem:pmi];
    }
}


@end
