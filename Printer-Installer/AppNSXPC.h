//
//  AppNSXPC.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Interfaces.h"

#import "Server.h"
#import "AppProgress.h"

@interface AppNSXPC : NSObject

+(void)addPrinter:(Printer*)printer;
+(void)removePrinter:(Printer*)printer;
+(void)tellHelperToQuit;

@end
