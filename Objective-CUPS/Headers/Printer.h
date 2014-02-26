//
//  Printer.h
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

/**Class for Adding, Removing & Modifying CUPS Printers*/
@interface Printer : NSObject
#pragma mark - Properties

/**CUPS compliant name for a printer destination*/
@property (copy,nonatomic) NSString *name;

/**FQDN or IP address to the CUPS Server or Printer */
@property (copy,nonatomic) NSString *host;

/**An approperiate protocol for the printer.  Currently avaliabel protocols are: ipp, http, https, socket, lpd, dnssd*/
@property (copy,nonatomic) NSString *protocol;

/**A human readable description of the printer */
@property (copy,nonatomic) NSString *description;

/**A human readable location of the printer */
@property (copy,nonatomic) NSString *location;

/** model name matching a result from lpinfo -m (end of each line)*/
@property (copy,nonatomic) NSString *model;

/** path where a PPD file can be download*/
@property (copy,nonatomic) NSString *ppd_url;

/** Array of options that use the lpoptions structure (e.g Option=Value).  
 A list of avaliable options can be obtained via lpoptions -p printer -l */
@property (copy,nonatomic) NSArray  *options;

/** Array of options that can get applied to the printer 
based on the model*/
@property (copy,nonatomic) NSArray  *avaliableOptions;


/**current state of printer */
@property (nonatomic)       OSStatus status;

/**currently printing jobs */
@property (nonatomic)       NSArray *jobs;

/**path to raw ppd file either .gz or .ppd */
@property (copy, nonatomic) NSString *ppd;

/**full uri for cups dest*/
@property (copy, nonatomic) NSString *url;

#pragma mark - Methods
/**
 initialize the Printer Object with a dictionary of matching keys

 @param dict Dictionary of keys.

 @note Required Keys: name, host, protocol, model.
 @note Optional Keys: description, location, options.
 
 @return self, initialized using dictionary.
 */
-(id)initWithDictionary:(NSDictionary*)dict;
#pragma mark - Add / Remove
/**
 Adds a Printer
 @param error initialized and set if error occurs
 @return Returns `YES` if printer was successfully added, or `NO` on failure.
 */
-(BOOL)addPrinter;                      //
-(BOOL)addPrinter:(NSError**)error;

/**
 remove a Printer
 @param error initialized and set if error occurs
 @return `YES` if printer was successfully remvoed, `NO` on failure
 */
-(BOOL)removePrinter;                   //
-(BOOL)removePrinter:(NSError**)error;

#pragma mark - Options
/**
 Adds a single option to the specified printer
 @param option single option
 @note must conform to lpoptions syntax
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)addOption:(NSString*)option;     // add single option conforming to lpoptions syntax
/**
 Adds an array of options to the specified printer
 @param options array of option
 @note must conform to lpoptions syntax
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)addOptions:(NSArray *)options;   // add list option conforming to lpoptions syntax

#pragma mark - Status Modifier
/**
 Enable Printer
 @param error initialized and set if error occurs
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)enable;
-(BOOL)enable:(NSError**)error;

/**
 Disable Printer
 @param error initialized and set if error occurs
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)disable;
-(BOOL)disable:(NSError**)error;

#pragma mark - Printer Jobs
/**
 description
 @param File Path to the file to print
 @param error initialized and set if error occurs
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)printFile:(NSString*)file;
-(BOOL)printFile:(NSString*)file error:(NSError**)error;

/**
 description
 @param URL to the file to print
 @note the url must be to a local file not a web address
 @param error initialized and set if error occurs
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)printFileAtURL:(NSURL*)file;
-(BOOL)printFileAtURL:(NSURL *)file error:(NSError**)error;

/**
 description
 @param
 @return Returns `YES` on success, or `NO` on failure.
 */
-(BOOL)cancelJobs;
-(BOOL)cancelJobs:(NSError**)error;
#pragma mark - Class Methods
/**
 Gets a list of the currently installed printers
 @return NSSet of installed printers
 */
+(NSSet *)installedPrinters;          //

/**
 Gets a list of the options avaliable for particular printer model
 @return NSSet of installed printers
 */
+(NSSet *)optionsForModel:(NSString*)model;

@end


