//
//  PICups.h
//  Printer-Installer
//
//  Created by Eldon on 10/18/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <cups/cups.h>

@interface PICups : NSObject
+(NSSet*)getInstalledPrinters;
@end
