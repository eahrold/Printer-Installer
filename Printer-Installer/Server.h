//
//  Server.h
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (copy) NSURL *URL;
@property (copy) NSString *port;

@property (copy) NSString *authName;
@property (copy) NSString *authPass;
@property (copy) NSString* fingerPrint;
@property (copy) NSString *authHeader;

@property (copy) NSData   *requestData;
@property (copy) NSError   *error;
@property (copy) NSURLResponse* response;

@property (nonatomic,readwrite) NSTimeInterval timeout;
@property (nonatomic,readwrite) NSURLRequestCachePolicy cachePolicy;

-(id)initWithURL:(NSURL*)URL;
-(id)initWithURLString:(NSString*)URL;

- (void)getRequestReturningData:(void(^)(NSData *data))data withError:(void (^)(NSError *error))error;
- (void)cancelConnections;


-(void)setBasicHeaders:(NSString*)header;
-(void)postRequestWithData;
-(NSData*)getRequest;

+(BOOL)checkURL:(NSString*)URL;
@end
