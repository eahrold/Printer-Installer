//
//  AppDelegate.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <cups/cups.h>
#import <ServiceManagement/ServiceManagement.h>
#import "Interfaces.h"
#import "Server.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet NSArrayController *arrayController;
    
    NSMutableArray *name;
    NSMutableArray *location;
    NSMutableArray *state;
    
    NSArray* printerList;

}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *addedPrinters;

@end
