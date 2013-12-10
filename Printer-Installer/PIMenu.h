//
//  PIStatusBar.h
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PICups.h"
#import "Printer.h"
#import "PIError.h"

@class PIMenu,PIController;

@protocol PIMenuDelegate <NSObject,NSMenuDelegate>
-(NSArray*)printersInPrinterList:(PIMenu*)piMenu;
-(void)uninstallHelper:(id)sender;
@end

@interface PIMenu : NSMenu

@property (weak) id<PIMenuDelegate>delegate;
-(void)updateMenuItems;


@end
