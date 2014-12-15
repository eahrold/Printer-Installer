//
//  PIMenu.h
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Printer.h"
#import "PIError.h"
#import "PIBonjourBrowser.h"
@class PIMenu,PIController;

@protocol PIMenuDelegate <NSObject,NSMenuDelegate>
    @property (strong) NSArray *printerList;
    @property (strong) NSMutableArray *bonjourPrinterList;
    -(void)uninstallHelper:(id)sender;
@end

@interface PIMenu : NSMenu <PIBonjourBrowserDelegate>

@property (weak) id<PIMenuDelegate>delegate;

-(void)updateMenuItems;
-(BOOL)displayBonjourMenu:(BOOL)display;
@end
