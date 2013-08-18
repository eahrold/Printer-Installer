//
//  Server.h
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject

@property (copy) NSString *URL;
@property (copy) NSString *port;
@property (copy) NSString *path;
@property (nonatomic) BOOL isSecure;

@property (copy) NSString *authName;
@property (copy) NSString *authPass;
@property (copy) NSString* fingerPrint;
@property (copy) NSString *authHeader;

@property (copy) NSData   *requestData;
@property (copy) NSError   *error;
@property (copy) NSURLResponse* response;



-(void)setBasicHeaders:(NSString*)header;
-(void)setGetListPath;


-(void)postRequestWithData;
-(NSDictionary*)getRequest;


@end
