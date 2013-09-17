//
//  Printer.h
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Printer : NSObject <NSSecureCoding>

@property (copy) NSString *name;
@property (copy) NSString *description;
@property (copy) NSString *location;

// ipp http https lpd socket
@property (copy) NSString *protocol;

// path to ppd file
@property (copy) NSString *ppd;

// model gathered using lpinfo
@property (copy) NSString *model;

@property (copy) NSString *host;
@property (copy) NSString *url;

-(void)setPrinterFromDictionary:(NSDictionary*)dict;

@end
