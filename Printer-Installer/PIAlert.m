//
//  PIAlert.m
//  Printer-Installer
//
//  Created by Eldon on 12/29/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIAlert.h"
#import <Cocoa/Cocoa.h>

@implementation PIAlert
+(void)showAlert:(NSString *)alert withDescription:(NSString *)msg{
    [self showAlert:alert withDescription:msg didEndSelector:NULL];
}

+(void)showAlert:(NSString *)alert withDescription:(NSString *)msg didEndSelector:(SEL)selector{
    if(!msg){
        msg = @"";
    }
    [[NSAlert alertWithMessageText:alert defaultButton:@"OK"
                   alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",msg]
     beginSheetModalForWindow:nil
     modalDelegate:[NSApp delegate]
     didEndSelector:selector
     contextInfo:NULL];
}

@end
