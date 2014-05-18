//
//  PIError.m
//  Printer-Installer
//
//  Created by Eldon on 11/2/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIError.h"

//  The Domain to user with error codes and Alert Panel
NSString* const PIDomain = @"edu.loyno.smc.Printer-Installer";
NSString* const PINoSharedGroups = @"There are no printers shared with that group at this time:";
NSString* const PIIncorrectURL = @"The URL you entered may not be correct, please try again:";
NSString* const PIIncorrectURLAlt = @"The URL still isn't right, please check again:";

NSString* errorTextForCode(int code){
    NSString * codeText = @"";
    switch (code) {
        case kPIErrorCouldNotAddLoginItem:codeText = @"There was a problem setting this app to launch at login, you should try to manually add it using System Preferences.";
            break;
        case kPIErrorServerNotFound:codeText = @"We could not locate the Managed Printer Server.  Try again later or contact your system admin";
            break;
        case kPIErrorCouldNotInstallHelper:codeText = @"The required helper tool could not be installed.  We must now quit.";
            break;
        default: codeText = @"There was a unknown problem, sorry!";
            break;
    }
    return codeText;
}

@implementation PIError
#ifdef _APPKITDEFINES_H
+(void)presentErrorWithCode:(PIErrorCode)code delegate:(id)sender didPresentSelector:(SEL)selector
{
    NSError* error;
    [[self class] errorWithCode:code error:&error];
    [self presentError:error delegate:sender didPresentSelector:selector];
}

+(void)presentError:(NSError *)error{
    [self presentError:error delegate:nil didPresentSelector:NULL];
}

+(void)presentError:(NSError *)error delegate:(id)sender didPresentSelector:(SEL)selector
{
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [NSApp presentError:error
             modalForWindow:NULL
                   delegate:sender
         didPresentSelector:selector
                contextInfo:NULL];
    }];
}
#endif

+ (BOOL)errorWithCode:(PIErrorCode)code error:(NSError *__autoreleasing *)error
{
    if(error)*error = [NSError errorWithDomain:PIDomain
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey:errorTextForCode(code)}];
    return NO;
}

@end
