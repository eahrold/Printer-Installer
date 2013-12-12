//
//  Interfaces.h
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Printer.h"
#import "PIError.h"

static NSString * const kHelperName = @"edu.loyno.smc.Printer-Installer.helper";

@protocol HelperAgent <NSObject>
-(void)addPrinter:(Printer*)printer
        withReply:(void (^)(NSError *error))reply;

-(void)removePrinter:(Printer*)printer
        withReply:(void (^)(NSError *error))reply;

-(void)helperInstallLoginItem:(NSURL*)loginItem;
-(void)quitHelper;
-(void)uninstall:(void (^)(NSError*))reply;

@end

@protocol HelperProgress
- (void)setProgress:(double)progress;
- (void)setProgress:(double)progress withMessage:(NSString*)message;
@end