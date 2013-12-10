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
#import "PILoginItem.h"


@implementation PIController{
    NSArray *printerList;
}

@synthesize piMenu;
@synthesize configSheet;

#pragma mark - setup
-(void)awakeFromNib {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(configureFromURLSheme:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:piMenu];
    [statusItem setImage:[NSImage imageNamed:@"StatusBar"]];
    [statusItem setHighlightMode:YES];
    [piMenu setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internet = [Reachability reachabilityForInternetConnection];
    [self.internet startNotifier];
    if([self.internet currentReachabilityStatus]){
        [self refreshPrinterList];
    }
}

- (void) reachabilityChanged:(NSNotification *)note
{
	self.internet = [note object];
	NSParameterAssert([self.internet isKindOfClass:[Reachability class]]);

    if([self.internet currentReachabilityStatus]){
        [self refreshPrinterList];
    }else{
    }
}

-(void)refreshPrinterList{
    NSString* url = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"server"];
    Server* server = [[Server alloc]initWithQueue];
    server.URL = [NSURL URLWithString:url];
    
    [server getRequestReturningData:^(NSData *data) {
        NSDictionary *settings =[NSDictionary dictionaryFromData:data];

        printerList = settings[@"printerList"];
        if(printerList.count){
            [piMenu updateMenuItems];
            [self cancelConfigSheet];
        }else{
            configSheet.panelMessage = @"There are no printers shared with that group at this time:";
        }

        NSString* feedURL = settings[@"updateServer"];

        if([Server checkURL:feedURL]){
            [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
        }else{
            feedURL = [[NSBundle mainBundle] infoDictionary][@"SUFeedURL"];
            [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
        }
    }withError:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        configSheet.panelMessage = @"The URL you entered may not be correct, please try again:";
        [configSheet.defaultsCancelButton setHidden:NO];
        [self performSelectorOnMainThread:@selector(configure:) withObject:self waitUntilDone:NO];

    }];
}

#pragma mark - PIConfigSheet delegate methods
-(void)cancelConfigSheet{
    [configSheet close];
    configSheet = nil;
}

-(BOOL)installLoginItem:(BOOL)state{
    return([PILoginItem installLoginItem:state]);
}

#pragma mark - IBActions
-(IBAction)quitNow:(id)sender{
    [NSApp terminate:self];
}

-(IBAction)configure:(id)sender{
    if(!configSheet){
        configSheet = [[PIConfigSheet alloc]initWithWindowNibName:@"ConfigSheet"];
        [configSheet setDelegate:self];
    }
    [configSheet showWindow:self];
}


#pragma mark - PIMenu delegate methods
-(NSArray*)printersInPrinterList:(PIMenu *)piMenu{
    return printerList;
}

-(void)uninstallHelper:(id)sender{
    [PINSXPC uninstallHelper];
}

#pragma mark - internal methods
-(void)managePrinter:(id)sender{
    NSMenuItem* pmi = sender;
    NSInteger pix = ([piMenu indexOfItem:pmi]-3);
    NSDictionary* printer = [printerList objectAtIndex:pix];
    
    if (!pmi.state){
        [PINSXPC addPrinter:printer menuItem:pmi];
    }else{
        [PINSXPC removePrinter:printer menuItem:pmi];
    }
}

- (void)configureFromURLSheme:(NSAppleEventDescriptor*)event
{
    // get the URL from the Event and change it to an actual web url
    // we register both printerinstaller and printerinstallers which
    // represent http and https respectively
    NSString* piurl = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *url = [piurl stringByReplacingOccurrencesOfString:@"printerinstaller" withString:@"http"];
    [[[NSUserDefaultsController sharedUserDefaultsController]values ]setValue:url forKey:@"server"];
    [self refreshPrinterList];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
