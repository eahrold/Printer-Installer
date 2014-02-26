//
//  PrinterJob.h
//  ObjectiveCups
//
//  Created by Eldon on 1/20/14.
//  Copyright (c) 2014 Loyola University New Orleans. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PrinterJob;
@protocol PrintJobMonitor <NSObject>
-(void)didRecieveStatusUpdate:(NSString*)msg job:(PrinterJob*)job;
@end


/**Class for Monitoring Print Jobs*/
@interface PrinterJob : NSObject

@property (weak) id<PrintJobMonitor>jobMonitor;

/**Name of the submitted print job*/
@property (copy) NSString  *name;

/**Printer dest of the submitted print job*/
@property (copy) NSString  *dest;

/**User who submitted the print job*/
@property (copy,nonatomic,readonly) NSString  *user;

/**Job ID number*/
@property (nonatomic,readonly) NSInteger jid;

/**Size of the print job in Bytes*/
@property (nonatomic,readonly) NSInteger size;

/**Status of the print job*/
@property (readonly,nonatomic) OSStatus status;

/**Date the print Job was submitted*/
@property   (nonatomic,readonly) NSInteger submitionDate;

/**Descriptive Status of the print job*/
@property (copy,nonatomic,readonly) NSString  *statusDescription;


-(void)addFile:(NSString*)file;
-(void)addFiles:(NSArray*)files;

-(BOOL)submit;
-(BOOL)submit:(NSError**)error;


-(BOOL)hold;
-(BOOL)hold:(NSError**)error;

-(BOOL)start;
-(BOOL)start:(NSError**)error;

-(BOOL)cancel;
-(BOOL)cancel:(NSError**)error;

+(NSArray*)jobsForPrinter:(NSString*)printer;
+(NSArray *)jobsForPrinter:(NSString *)printer includeCompleted:(BOOL)include;

+(NSArray*)jobsForAllPrinters;
+(NSArray *)jobsForAllPrinterIncludingCompleted:(BOOL)includeCompleted;

+(void)cancelAllJobs;
+(BOOL)cancelJobWithID:(NSInteger)jid;
+(BOOL)cancelJobWithID:(NSInteger)jid error:(NSError**)error;

+(BOOL)cancelJobNamed:(NSString *)name;
+(BOOL)cancelJobNamed:(NSString *)name error:(NSError**)error;


@end
