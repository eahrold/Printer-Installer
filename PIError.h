//
//  PIError.h
//  Printer-Installer
//
//  Created by Eldon on 11/2/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString* const PIDomain;

@interface PIError : NSError
+ (NSError*) errorWithCode:(int)code;
+ (NSError*) errorWithCode:(NSInteger)rc message:(NSString*)msg;
+ (NSError*) cupsError:(int)rc message:(const char*)msg;
@end

enum PIErrorCodes {
    PISuccess = 0,
    PIPPDNotFound = 1001 ,
    PIInvalidProtocol = 1002 ,
    PIBadURL = 1003,
    PIServerNotFound = 1004,
    PICantWriteFile = 1005 ,
    PICantOpenPPD = 1006,
};
