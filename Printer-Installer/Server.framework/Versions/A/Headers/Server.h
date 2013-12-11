//
//  Server.h
//  Server Framework
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+NSData.h"
#import "NSString+NSData.h"

@interface Server : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (copy) NSURL    *URL;
@property (copy) NSString *port;

@property (copy) NSString *authName;
@property (copy) NSString *authPass;
@property (copy) NSString *fingerPrint;
@property (copy) NSString *authHeader;

@property (copy) NSData   *requestData;
@property (copy) NSHTTPURLResponse   *response;


@property (nonatomic,readwrite) NSTimeInterval timeout;
@property (nonatomic,readwrite) NSURLRequestCachePolicy cachePolicy;

-(id)initWithQueue;
-(id)initWithURL:(NSURL*)URL;
-(id)initWithURLString:(NSString*)URL;

-(void)setAuthHeaderWithUser:(NSString*)name andPassword:(NSString*)pass;
-(void)setAuthHeaderWithHeader:(NSString*)header;

-(BOOL)getRequest:(NSData**)data withError:(NSError**)error;

-(void)getRequestReturningData:(void(^)(NSData *data,NSError *error))reply;

-(BOOL)postRequest:(NSData*)data withError:(NSError**)error;

-(void)cancelConnections;


+(BOOL)checkURL:(NSString*)URL __deprecated;
+(void)checkURL:(NSString*)URL status:(void(^)(BOOL avaliable))reply;

@end
