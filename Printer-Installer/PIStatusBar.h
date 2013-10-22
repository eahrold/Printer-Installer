//
//  PIStatusBar.h
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PICups.h"
#import "Server.h"

@interface PIStatusBar : NSStatusBar

@property (nonatomic, strong) NSArray* printerList;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSSet* currentManagedPrinters;

-(void)RefreshPrinters;
-(id)initPrinterMenu;

@end
