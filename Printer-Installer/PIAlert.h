//
//  PIAlert.h
//  Printer-Installer
//
//  Created by Eldon on 12/29/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PIAlert : NSObject
+(void)showAlert:(NSString *)alert withDescription:(NSString *)msg didEndSelector:(SEL)selector;
+(void)showAlert:(NSString *)alert withDescription:(NSString *)msg;

@end
