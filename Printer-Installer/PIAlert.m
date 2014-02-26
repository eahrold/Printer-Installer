//
//  PIAlert.m
//  Printer-Installer
//
//  Created by Eldon on 12/29/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIAlert.h"
#import <Cocoa/Cocoa.h>

NSDictionary* alertFromCode(PIAlertCode code){
    NSString* message;
    NSString* description;
    switch (code) {
        case kPIAlertHelperToolRemoved:
            message = @"";
            description = @"";
            break;
        default:
            message = @"This was recieved in error";
            description = @"Please report you saw this to the system admin";
            break;
    }
    return @{@"msg":message,@"des":description};
}

@implementation PIAlert

+(void)showAlertWithCode:(PIAlertCode)code didEndSelector:(SEL)selector{
    NSDictionary* dict = alertFromCode(code);
    [self showAlert:dict[@"msg"] withDescription:dict[@"des"] didEndSelector:selector];
}


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
