//
//  Printer.h
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Printer : NSObject

@property (copy) NSString *name;
@property (copy) NSString *host;
@property (copy) NSString *protocol; // ipp, http, https, socket or lpd
@property (copy) NSString *description;
@property (copy) NSString *location;
@property (copy) NSString *model;
@property (copy) NSString *ppd_url; // path where ppd can be downloads
@property (copy) NSArray *options;

@property (copy) NSString *ppd; // path to ppd file
@property (copy) NSString *url; // full uri for cups dest

@property (copy) NSError *error;

-(void)configureURL;
-(void)configurePPD;

-(id)initWithDict:(NSDictionary*)dict;

@end
