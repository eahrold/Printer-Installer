//
//  AppTable.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <cups/cups.h>

#import "Server.h"
#import "AppNSXPC.h"
#import "AppPannel.h"


@interface AppTable : NSObject <NSTableViewDelegate, NSTableViewDataSource>{
    
    NSMutableArray *name;
    NSMutableArray *location;
    NSMutableArray *state;
    NSMutableArray *model;
    
    NSArray* printerList;

}


@end
