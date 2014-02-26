//
//  PINSXPC.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Server/Server.h>

#import "Interfaces.h"

static NSString * const kHelperName;

@interface PINSXPC : NSXPCConnection

-(id)initConnection;
+(void)changePrinterAvaliablily:(Printer*)printer add:(BOOL)added reply:(void (^)(NSError *error))reply;

+(void)tellHelperToQuit;
+(void)uninstallHelper;

@end
