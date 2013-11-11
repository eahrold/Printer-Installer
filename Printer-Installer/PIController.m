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

#pragma mark - PIConfigSheet delegate methods
-(void)cancelConfigSheet{
    [configSheet close];
    configSheet = nil;
}

-(BOOL)installLoginItem:(BOOL)state{
    BOOL status = YES;
    NSError* error;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef loginItem = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if(state){
        //Adding Login Item
        if (loginItems) {
            LSSharedFileListItemRef ourLoginItem = LSSharedFileListInsertItemURL(loginItems,
                                                                            kLSSharedFileListItemLast,
                                                                                 NULL, NULL,
                                                                                 loginItem,
                                                                                 NULL, NULL);
            if (ourLoginItem) {
                CFRelease(ourLoginItem);
            } else {
                NSLog(@"Could not insert ourselves as a login item");
                error = [PIError errorWithCode:PICouldNotAddLoginItem];
                status = NO;
            }
            CFRelease(loginItems);
        } else {
            NSLog(@"Could not get the login items");
            error = [PIError errorWithCode:PICouldNotAddLoginItem];
            status = NO;
        }
        if(error)[NSApp presentError:error];
        
    }else{
        //Removing Login Item
        if (loginItem){
            UInt32 seedValue;
            //Retrieve the list of Login Items and cast them to
            // a NSArray so that it will be easier to iterate.
            NSArray  *loginItemsArray = CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
            for( id i in loginItemsArray){
                LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)i;
                //Resolve the item with URL
                if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &loginItem, NULL) == noErr) {
                    NSString * urlPath = [(__bridge NSURL*)loginItem path];
                    if ([urlPath compare:appPath] == NSOrderedSame){
                        LSSharedFileListItemRemove(loginItems,itemRef);
                    }
                }
            }
        }
        CFRelease(loginItems);
    }
    return status;
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
        configSheet = [[PIConfigSheet alloc]initWithWindowNibName:@"ConfigSheet"];
        [configSheet setDelegate:self];
    }
    [configSheet showWindow:self];
}


#pragma mark - PIMenu delegate methods
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
