//
//  Printer.h
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Printer : NSObject <NSSecureCoding>

@property (copy) NSString *name;        // CUPS compliant name for a printer destination
@property (copy) NSString *host;        // fqdn or ip address of CUPS Server or Printer
@property (copy) NSString *protocol;    // ipp, http, https, socket or lpd
@property (copy) NSString *description; // a human readable description of the printer
@property (copy) NSString *location;    // a human readable location
@property (copy) NSString *model;       // model name matching the an lpinfo -m (end of each line)
@property (copy) NSString *ppd_url;     // path where ppd can be downloads
@property (copy) NSArray  *options;     // List of options that use the lpoptions structure
@property (copy) NSString *ppd;         // path to raw ppd file either .gz or .ppd
@property (copy) NSString *url;         // full uri for cups dest

@property (copy) NSError *error;

-(id)initWithDictionary:(NSDictionary*)dict;

-(BOOL)configureURI;    // try and configure a Printer URI from the protocol-host-name keys

// Objective-C wrappers for CUPS
+(NSSet*)getInstalledPrinters;  //Returns A list of all installed printers

-(BOOL)addPrinter;  // adds a Printer object
-(BOOL)removePrinter;  // remove a Printer object

@end
