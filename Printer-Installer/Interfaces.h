//
//  Interfaces.h
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PIError.h"
@class OCPrinter;
static NSString * const kHelperName = @"edu.loyno.smc.Printer-Installer.helper";

@protocol HelperAgent <NSObject>
-(void)addPrinter:(OCPrinter*)printer
        withReply:(void (^)(NSError *error))reply;

-(void)removePrinter:(OCPrinter*)printer
        withReply:(void (^)(NSError *error))reply;

-(void)quitHelper:(void (^)(BOOL success))reply;
-(void)uninstall:(void (^)(NSError*))reply;

@end

@protocol HelperProgress
- (void)setProgress:(double)progress;
- (void)setProgress:(double)progress withMessage:(NSString*)message;
@end