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
@property (copy,nonatomic) NSString *ppd;         // path to raw ppd file either .gz or .ppd
@property (copy,nonatomic) NSString *url;         // full uri for cups dest

-(id)initWithDictionary:(NSDictionary*)dict;


// Objective-C wrappers for CUPS
+(NSSet*)getInstalledPrinters;          //Returns A list of all installed printers

-(BOOL)addPrinter:(NSError**)error;
-(BOOL)addPrinter;                      // adds a Printer object

-(BOOL)removePrinter:(NSError**)error;
-(BOOL)removePrinter;                   // remove a Printer object
-(BOOL)addOption:(NSString*)option;     // add single option conforming to lpoptions syntax
-(BOOL)addOptions:(NSArray *)options;   // add list option conforming to lpoptions syntax

@end
