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
#import "PIMenuView.h"


@implementation PIController{
    PIMenuView   *_menuView;
    PIConfigView *_configView;
    NSStatusItem *_statusItem;
    NSArray      *_printerList;
    NSPopover    *_popover;

}

@synthesize menu = _menu;

#pragma mark - Setup / Tear Down
-(void)awakeFromNib {
    // Setup Reachability
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(configureFromURLSheme:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internet = [Reachability reachabilityForInternetConnection];
    [self.internet startNotifier];
    
    // Setup Status Item
    _statusItem = [[NSStatusBar systemStatusBar]statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menu];
    [_statusItem setHighlightMode:YES];
    [_menu setDelegate:self];
    
    if(!_menuView){
        _menuView = [[PIMenuView alloc]initWithStatusItem:_statusItem andMenu:_menu];
    }
    
    _statusItem.view = _menuView;
    
    // If we have Internet Connectivity try and downlaod the list from the server,
    // Otherwise, get notified when we do and pick up there...
    if([self.internet currentReachabilityStatus]){
        [self refreshPrinterList];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


- (void) reachabilityChanged:(NSNotification *)note
{
	self.internet = [note object];
	NSParameterAssert([self.internet isKindOfClass:[Reachability class]]);

    if([self.internet currentReachabilityStatus]){
        [self refreshPrinterList];
    }
}

-(void)refreshPrinterList{
    NSString* url = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"server"];
    Server* server = [[Server alloc]initWithQueue];
    server.URL = [NSURL URLWithString:url];
    
    [server getRequestReturningData:^(NSData *data) {
        NSDictionary *settings =[NSDictionary dictionaryFromData:data];

        _printerList = settings[@"printerList"];
        if(_printerList.count){
            [_menu updateMenuItems];
            [self cancelConfigView];
        }else{
            _configView.panelMessage = @"There are no printers shared with that group at this time:";
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
        _configView.panelMessage = @"The URL you entered may not be correct, please try again:";
        [_configView.defaultsCancelButton setHidden:NO];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self configure:self];
        }];

    }];
}

#pragma mark - PIConfigSheet delegate methods
-(void)cancelConfigView{
    if (_popover != nil && _popover.isShown) {
        [_popover close];
    }
    
    ((PIDelegate*)[NSApp delegate]).popupIsActive = NO;
    _configView = nil;
}

-(BOOL)installLoginItem:(BOOL)state{
    return([PILoginItem installLoginItem:state]);
}

#pragma mark - IBActions
-(IBAction)quitNow:(id)sender{
    [NSApp terminate:self];
}

-(IBAction)configure:(id)sender{
    if(!_configView){
        _configView = [[PIConfigView alloc]initWithNibName:@"PIConfigView" bundle:nil];
        [_configView setDelegate:self];
    }
    
    if (_popover == nil) {
        _popover = [[NSPopover alloc] init];
        _popover.contentViewController = _configView;
    }
    
    
    if (!_popover.isShown) {
        [_popover showRelativeToRect:_menuView.frame
                              ofView:_menuView
                       preferredEdge:NSMinYEdge];
    }
    ((PIDelegate*)[NSApp delegate]).popupIsActive = _popover.isShown;
}

#pragma mark - internal methods
-(void)managePrinter:(id)sender{
    NSMenuItem* pmi = sender;
    NSInteger pix = ([_menu indexOfItem:pmi]-3);
    NSDictionary* printer = [_printerList objectAtIndex:pix];
    
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



#pragma mark - PIMenu delegate methods
-(NSArray*)printersInPrinterList:(PIMenu *)piMenu{
    return _printerList;
}

-(void)uninstallHelper:(id)sender{
    [PINSXPC uninstallHelper];
}

#pragma mark - NSMenuDelegate
- (void)menuDidClose:(NSMenu *)menu
{
    [_menuView setActive:NO];
}



@end
