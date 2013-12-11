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

@implementation PIError

+ (NSError*) errorWithCode:(int)code
{
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:[PIError errorTextForCode:code], NSLocalizedDescriptionKey, nil];
    return [self errorWithDomain:PIDomain code:code userInfo:info];
}

+ (NSError*) errorWithCode:(NSInteger)code message:(NSString*)msg
{
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil];
    return [self errorWithDomain:PIDomain code:code userInfo:info];
}

+ (NSError*) cupsError:(int)code message:(const char*)msg
{
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%s",msg], NSLocalizedDescriptionKey, nil];
    return [self errorWithDomain:PIDomain code:code userInfo:info];
}


+(NSString *) errorTextForCode:(int)code {
    NSString * codeText = @"";
    switch (code) {
        case PIBadURL: codeText = @"The URL to the printer is incorrect.  Contact the system Admin";
            break;
        case PIPPDNotFound: codeText = @"No PPD Avaliable, please download and install the drivers from the manufacturer.";
            break;
        case PIInvalidProtocol:codeText = @"That url scheme is not supported at this time";
            break;
        case PICantWriteFile:codeText = @"lpadmin: Unable to open PPD file";
            break;
        case PICantOpenPPD:codeText = @"lpadmin: Unable to open PPD file";
            break;
        case PICouldNotAddLoginItem:codeText = @"There was a problem setting this app to launch at login, you should try to manually add it using System Preferences.";
            break;
        default: codeText = @"There was a unknown problem, sorry!";
            break;
            
    }
    return codeText;
}

@end
