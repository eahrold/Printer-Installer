//
//  Interfaces.h
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Printer.h"

static NSString * const kHelperName = @"edu.loyno.smc.Printer-Installer.helper";


@protocol HelperAgent <NSObject>
-(void)addPrinter:(NSDictionary*)printer
        withReply:(void (^)(NSError *error))reply;

-(void)removePrinter:(NSDictionary*)printer
        withReply:(void (^)(NSError *error))reply;

-(void)quitHelper;

@end

@protocol HelperProgress
- (void)setProgress:(double)progress;
- (void)setProgress:(double)progress withMessage:(NSString*)message;
@end