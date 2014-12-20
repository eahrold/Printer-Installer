//
//  PIController.m
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIController.h"
#import "PIDelegate.h"
#import "PINSXPC.h"
#import "PILoginItem.h"
#import "PIMenuView.h"

#import <AFNetworking/AFNetworking.h>
#import <Objective-CUPS/Objective-CUPS.h>
#import <Sparkle/SUUpdater.h>
#import <XMLDictionary/XMLDictionary.h>

@implementation PIController {
    PIMenuView *_menuView;
    PIConfigView *_configView;
    NSStatusItem *_statusItem;
    NSPopover *_popover;
    NSNetServiceBrowser *_bonjourBrowser;
    PIBonjourBrowser *_bonjourBrowserDelegate;
}

@synthesize bonjourPrinterList = _bonjourPrinterList;
@synthesize printerList = _printerList;

#pragma mark - Setup / Tear Down
- (void)dealloc
{
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:nil];

    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)awakeFromNib
{
    // Setup Reachability

    NSURL *serverURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"server"]];

    if (serverURL) {
        self.internet = [Reachability reachabilityWithHostName:serverURL.host];
    } else {
        self.internet = [Reachability reachabilityForInternetConnection];
    }

    [self.internet startNotifier];

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(configureFromURLSheme:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];

    // Setup Observers

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"ShowBonjourPrinters"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];

    // Setup Status Item
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menu];
    [_statusItem setHighlightMode:YES];
    [_menu setDelegate:self];

    if (!_menuView) {
        _menuView = [[PIMenuView alloc] initWithStatusItem:_statusItem andMenu:_menu];
    }
    _statusItem.view = _menuView;

    // Add items into the menu
    _printerList = [[NSUserDefaults standardUserDefaults] objectForKey:@"PrinterList"];
    [_menu updateMenuItems];
    [self checkPrinterSettings];
}

#pragma mark - Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"ShowBonjourPrinters"]) {
        [self enableBonjourPrinters:[[change valueForKey:@"new"] boolValue]];
    }
}

#pragma mark - Reachability
- (void)reachabilityChanged:(NSNotification *)note
{
    self.internet = [note object];
    NSParameterAssert([self.internet isKindOfClass:[Reachability class]]);

    if ([self.internet currentReachabilityStatus]) {
        [self refreshPrinterList];
    }
}

- (void)refreshPrinterList
{
    NSController *values = [[NSUserDefaultsController sharedUserDefaultsController] values];

    NSString *url = [[values valueForKey:@"server"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];

    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *settings = [self dataToDictionary:responseObject];
        NSArray* printerList = settings[@"printerList"];
        
        if(printerList.count){
            [[NSUserDefaults standardUserDefaults] setObject:printerList forKey:@"PrinterList"];
            _printerList = printerList;
            [_menu updateMenuItems];
            [self checkPrinterSettings];
            [self cancelConfigView];
        }else{
            _configView.panelMessage = PINoSharedGroups;
        }

        // If we get a server repsonse with the appcast url
        // check to see if the server is actually responding
        // at that address, and if not set it to the default
        NSString* appCastURL = settings[@"updateServer"];
        if (appCastURL) {
            [manager GET:appCastURL parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:appCastURL]];

                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSString *feedURL = [[NSBundle mainBundle] infoDictionary][@"SUFeedURL"];
                     if(feedURL){
                         [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
                     }
                 }];
        };
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(error){
            NSLog(@"%@",error.localizedDescription);
            if(_configView){
                // we switch between messages so the use knows something is happening
                _configView.panelMessage = [_configView.panelMessage isEqualToString:PIIncorrectURLAlt] ? PIIncorrectURL:PIIncorrectURLAlt;
            }else if(_printerList){
                [_menu updateMenuItems];
            }
        }
    }];
}

- (void)enableBonjourPrinters:(BOOL)enable
{
    [_menu displayBonjourMenu:enable];
    if (enable) {
        if (!_bonjourBrowserDelegate) {
            _bonjourBrowserDelegate = [[PIBonjourBrowser alloc] initWithDelegate:_menu];
        }

        if (!_bonjourBrowser) {
            _bonjourBrowser = [[NSNetServiceBrowser alloc] init];
            _bonjourBrowser.delegate = _bonjourBrowserDelegate;
        }

        [_bonjourBrowser searchForServicesOfType:@"_printer._tcp." inDomain:@"local"];
    } else {
        for (NSNetService *service in _bonjourBrowserDelegate.services) {
            [service stopMonitoring];
        }
        _bonjourBrowserDelegate = nil;
        _bonjourBrowser = nil;
    }
}

#pragma mark - PIConfigSheet delegate methods
- (void)cancelConfigView
{
    if (_popover != nil && _popover.isShown) {
        [_popover close];
    }

    ((PIDelegate *)[NSApp delegate]).popupIsActive = NO;
    _configView = nil;
}

- (BOOL)installLoginItem:(BOOL)state
{
    return ([PILoginItem installLoginItem:state]);
}

#pragma mark - IBActions
- (IBAction)quitNow:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)configure:(id)sender
{
    if (!_configView) {
        _configView = [[PIConfigView alloc] initWithNibName:@"PIConfigView" bundle:nil];
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
    ((PIDelegate *)[NSApp delegate]).popupIsActive = _popover.isShown;
}

#pragma mark - internal methods
- (void)managePrinter:(NSMenuItem *)sender
{
    NSInteger pix = [_menu indexOfItem:sender] - 3;
    OCPrinter *printer = [[OCPrinter alloc] initWithDictionary:_printerList[pix]];
    [PINSXPC changePrinterAvaliablily:printer add:!sender.state reply:^(NSError *error) {
            if(!error)
                sender.state = !sender.state;
            else
                [PIError presentError:error];
    }];
}

- (void)checkPrinterSettings
{
    for (NSDictionary *pDict in _printerList) {
        OCPrinter *printer = [[OCPrinter alloc] initWithDictionary:pDict];
        for (OCPrinter *installedPrinter in [OCManager installedPrinters]) {
            if ([printer.name isEqualToString:installedPrinter.name]) {
                if (![printer.uri isEqualToString:installedPrinter.uri]) {
                    NSLog(@"Updating uri for %@", printer);
                    [PINSXPC changePrinterAvaliablily:printer
                                                  add:YES
                                                reply:^(NSError *error) {
                                                    if(error)
                                                        [PIError presentError:error];
                                                }];
                }
            }
        }
    }
}

- (void)manageBonjourPrinter:(NSMenuItem *)sender
{
    for (OCPrinter *printer in _bonjourPrinterList) {
        if ([printer.name isEqualToString:sender.title] ||
            [printer.description isEqualToString:sender.title]) {
            [PINSXPC changePrinterAvaliablily:printer add:!sender.state reply:^(NSError *error) {
                    if(!error)
                        sender.state = !sender.state;
                    else
                        [PIError presentError:error];
            }];
            return;
        }
    }
}

- (void)manageSubscribedPrinters:(NSDictionary *)subnetDictionary
{
    NSString *currentSubnet = @"";
    NSSet *installedPrinters = [OCManager installedPrinters];
    for (OCPrinter *printer in installedPrinters) {
        if (![printer.location isEqualToString:[currentSubnet stringByAppendingPathExtension:@"pi-printer"]]) {
            // remove printer
        }
    }
}

- (void)configureFromURLSheme:(NSAppleEventDescriptor *)event
{
    // get the URL from the Event and change it to an actual web url
    // we register both printerinstaller and printerinstallers which
    // represent http and https respectively
    NSString *piurl = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

    NSString *rebuiltURL = [piurl stringByReplacingOccurrencesOfString:@"printerinstaller" withString:@"http"];

    [[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:rebuiltURL
                                                                        forKey:@"server"];

    [self refreshPrinterList];
}

#pragma mark - PIMenu delegate methods
- (NSArray *)printersInPrinterList:(PIMenu *)piMenu
{
    return _printerList;
}

- (void)uninstallHelper:(id)sender
{
    [PINSXPC uninstallHelper];
}

#pragma mark - NSMenuDelegate
- (void)menuDidClose:(NSMenu *)menu
{
    [_menuView setActive:NO];
}

#pragma mark - Utility
- (NSDictionary *)dataToDictionary:(id)data;
{
    NSMutableData *md = [NSMutableData dataWithCapacity:1024];
    [md appendData:data];

    NSPropertyListFormat plist;
    NSDictionary *dict = (NSDictionary *)[NSPropertyListSerialization
        propertyListWithData:md
                     options:NSPropertyListMutableContainersAndLeaves
                      format:&plist
                       error:nil];
    return dict;
}

@end
