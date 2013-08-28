//
//  AppDelegate.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>
#import <cups/cups.h>

#include "Interfaces.h"
#include "Server.h"
#include "Helper-SMJobBless.h"
#include "AppNSXPC.h"
#import "AppTable.h"
#import "AppProgress.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSArray* printerList;

}

@property (assign) IBOutlet NSWindow *window;

@end
