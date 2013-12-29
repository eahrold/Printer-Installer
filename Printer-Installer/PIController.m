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
    
    _printerList = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterList"];
    
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
    [[NSStatusBar systemStatusBar]removeStatusItem:_statusItem];
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
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    NSString* url = [values valueForKey:@"server" ];
    
    Server* server = [[Server alloc]initWithQueue];
    server.URL = [NSURL URLWithString:url];
    
    [server getRequestReturningData:^(NSData *data, NSError *error) {
        if(error){
            NSLog(@"%@",error.localizedDescription);
            if(_configView){
                // we switch between messages so the use knows something is happening
                _configView.panelMessage = [_configView.panelMessage isEqualToString:PIIncorrectURLAlt] ? PIIncorrectURL:PIIncorrectURLAlt;
            }else if(_printerList){
                [_menu updateMenuItems];
            }
        }else if (data){
            NSDictionary *settings =[NSDictionary dictionaryFromData:data];
            NSArray* printerList = settings[@"printerList"];
            if(printerList.count){
                [[NSUserDefaults standardUserDefaults]setObject:printerList forKey:@"PrinterList"];
                _printerList = printerList;
                [_menu updateMenuItems];
                [self cancelConfigView];
            }else{
                _configView.panelMessage = PINoSharedGroups;
            }
            
            // check if the Serever Provided us with a feedURL if so use that.
            // If not use the one provided int the App's Info.plist
            NSString* feedURL = settings[@"updateServer"];
            [Server checkURL:feedURL status:^(BOOL avaliable) {
                if(avaliable){
                    [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
                }else{
                    NSString *feedURL = [[NSBundle mainBundle] infoDictionary][@"SUFeedURL"];
                    if(feedURL){
                        [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
                    }
                }
             }];
        }
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
    }
    [_configView setDelegate:self];

    if (!_popover) {
        _popover = [[NSPopover alloc] init];
    }
    [_popover setContentViewController:_configView];

    if (!_popover.isShown) {
        [_popover showRelativeToRect:_menuView.frame
                              ofView:_menuView
                       preferredEdge:NSMinYEdge];
    }
    ((PIDelegate*)[NSApp delegate]).popupIsActive = _popover.isShown;
}

#pragma mark - internal methods
-(void)managePrinter:(NSMenuItem*)sender{
    NSInteger pix = ([_menu indexOfItem:sender]-3);
    Printer* printer = [[Printer alloc]initWithDictionary:_printerList[pix]];
    [PINSXPC changePrinterAvaliablily:printer add:!sender.state reply:^(NSError* error) {
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if(!error)sender.state = !sender.state;
            else [NSApp presentError:error];
        }];
    }];
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
