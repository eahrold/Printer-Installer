//
//  PIController.m
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Sparkle/SUUpdater.h>
#import <AHServers/AHServers.h>
#import "PIController.h"
#import "PIDelegate.h"
#import "PINSXPC.h"
#import "PILoginItem.h"
#import "PIMenuView.h"
#import "Printer.h"
#import "CUPSManager.h"

@implementation PIController{
    PIMenuView   *_menuView;
    PIConfigView *_configView;
    NSStatusItem *_statusItem;
    NSPopover    *_popover;
    NSNetServiceBrowser *_bonjourBrowser;
    PIBonjourBrowser    *_bonjourBrowserDelegate;
}

@synthesize bonjourPrinterList = _bonjourPrinterList;
@synthesize printerList = _printerList;

#pragma mark - Setup / Tear Down
- (void)dealloc
{
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self];
    [[NSStatusBar systemStatusBar]removeStatusItem:_statusItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

-(void)awakeFromNib {
    // Setup Reachability
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(configureFromURLSheme:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"ShowBonjourPrinters" options:NSKeyValueObservingOptionNew context:NULL];
    
    _printerList = [[NSUserDefaults standardUserDefaults]objectForKey:@"PrinterList"];
    
    NSURL* serverURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"server"]];
    
    if(serverURL){
        self.internet = [Reachability reachabilityWithHostName:serverURL.host];
    }else{
        self.internet = [Reachability reachabilityForInternetConnection];
    }
    
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
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"ShowBonjourPrinters"]){
        [self enableBonjourPrinters:[[change valueForKey:@"new"] boolValue]];
    }
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
    
    AHHttpManager* server = [[AHHttpManager alloc]initWithQueue];
    server.URL = [NSURL URLWithString:url];
    
    [server GET:^(NSData *data, NSError *error) {
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
                [self checkPrinterSettings];
                [self cancelConfigView];
            }else{
                _configView.panelMessage = PINoSharedGroups;
            }
            
            // check if the Serever Provided us with a feedURL if so use that.
            // If not use the one provided int the App's Info.plist
            NSString* feedURL = settings[@"updateServer"];
            [AHHttpRequest checkURL:feedURL status:^(BOOL avaliable) {
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

-(void)enableBonjourPrinters:(BOOL)enable{
    [_menu displayBonjourMenu:enable];
    if(enable){
        if(!_bonjourBrowserDelegate){
            _bonjourBrowserDelegate = [[PIBonjourBrowser alloc]initWithDelegate:_menu];
        }
        
        if(!_bonjourBrowser){
            _bonjourBrowser = [[NSNetServiceBrowser alloc]init];
            _bonjourBrowser.delegate = _bonjourBrowserDelegate;
        }
        
        [_bonjourBrowser searchForServicesOfType:@"_printer._tcp." inDomain:@"local"];
    }else{
        for(NSNetService* service in _bonjourBrowserDelegate.services){
            [service stopMonitoring];
        }
        _bonjourBrowserDelegate = nil;
        _bonjourBrowser = nil;
    }
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
    NSInteger pix = [_menu indexOfItem:sender]-3;
    Printer* printer = [[Printer alloc]initWithDictionary:_printerList[pix]];
    [PINSXPC changePrinterAvaliablily:printer add:!sender.state reply:^(NSError* error) {
            if(!error)
                sender.state = !sender.state;
            else
                [PIError presentError:error];
    }];
}

-(void)checkPrinterSettings{
    for(NSDictionary *pDict in _printerList){
        Printer *printer = [[Printer alloc]initWithDictionary:pDict];
        for(Printer *installedPrinter in [CUPSManager installedPrinters]){
            if([printer.name isEqualToString:installedPrinter.name]){
                if(![printer.url isEqualToString:installedPrinter.url]){
                    NSLog(@"Updating uri for %@",printer);
                    [PINSXPC changePrinterAvaliablily:printer
                                                  add:YES
                                                reply:^(NSError* error){
                                                    if(error)
                                                        [PIError presentError:error];
                                                }];
                }
            }
        }
    }
}

-(void)manageBonjourPrinter:(NSMenuItem*)sender{
    for(Printer* printer in _bonjourPrinterList){
        if([printer.name isEqualToString:sender.title ]||
            [printer.description isEqualToString:sender.title ]){
            [PINSXPC changePrinterAvaliablily:printer add:!sender.state reply:^(NSError* error) {
                    if(!error)
                        sender.state = !sender.state;
                    else
                        [PIError presentError:error];
            }];
            return;
        }
    }
}

- (void)configureFromURLSheme:(NSAppleEventDescriptor*)event
{
    // get the URL from the Event and change it to an actual web url
    // we register both printerinstaller and printerinstallers which
    // represent http and https respectively
    NSString* piurl = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL* url = [NSURL URLWithString:piurl];
    
    NSString *scheme;
    if([url.scheme isEqualToString:@"printerinstaller"]){
        scheme = @"http";
    }else if([url.scheme isEqualToString:@"printerinstallers"]){
        scheme = @"https";
    }
    
    NSString *newURL = [NSString stringWithFormat:@"%@://%@%@",scheme,url.host,url.path];
    
    [[[NSUserDefaultsController sharedUserDefaultsController]values ]setValue:newURL forKey:@"server"];
    [self refreshPrinterList];
}


#pragma mark - PIMenu delegate methods
-(NSArray*)printersInPrinterList:(PIMenu *)piMenu{
    return _printerList;
}

-(void)uninstallHelper:(id)sender
{
    [PINSXPC uninstallHelper];
}

#pragma mark - NSMenuDelegate
- (void)menuDidClose:(NSMenu *)menu
{
    [_menuView setActive:NO];
}




@end
