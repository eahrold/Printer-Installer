//
//  Server.m
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Server.h"
#import <SecurityInterface/SFCertificateTrustPanel.h>

@interface ServerURLConnection : NSURLConnection

@property (nonatomic,readwrite,strong) void(^ServerData)(NSData *data);
@property (nonatomic,readwrite,strong) void(^ServerError)(NSError *error);
@property (nonatomic,readwrite,strong) NSMutableData *data;
@property (nonatomic,readwrite,strong) NSURLResponse *response;
@property (nonatomic,readwrite,strong) NSError *error;

@end

@implementation ServerURLConnection

@end

@interface Server()

@property (nonatomic,readwrite,strong) NSMutableArray *connections;
@property (nonatomic,readwrite,strong) NSOperationQueue *connectionQueue;

@end

@implementation Server

- (id)init{
    self = [super init];
    if (self) {
        _connectionQueue = [NSOperationQueue mainQueue];
        _connectionQueue.maxConcurrentOperationCount = 1;
        _connections = [NSMutableArray arrayWithCapacity:10];
        _timeout = 5.0;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return self;
}

- (id)initWithQueue{
    self = [self init];
    if (self) {
        _connectionQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(id)initWithURL:(NSURL*)url{
    self = [self init];
    if (self) {
        self.URL= url;
    }
    return self;
}

-(id)initWithURLString:(NSString*)url{
    self = [self init];
    if (self) {
        if(url)self.URL= [NSURL URLWithString:url];
    }
    return self;
}

-(void)getRequestReturningData:(void(^)(NSData *data))data withError:(void (^)(NSError *error))error{
    if (!self.URL) {
        error([NSError errorWithDomain:[[NSBundle mainBundle]bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey: @"NO URL Specified!"}]);
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL cachePolicy:self.cachePolicy timeoutInterval:self.timeout];
    ServerURLConnection *connection = [[ServerURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    if (!connection) {
        error([NSError errorWithDomain:[[NSBundle mainBundle]bundleIdentifier] code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Could not initialize NSURLConnection"}]);
        return;
    }
    
    [connection setDelegateQueue:self.connectionQueue];
    connection.data = [NSMutableData dataWithCapacity:1024];
    
    connection.ServerData = data;
    connection.ServerError = error;
    [connection start];
    
    [self.connections addObject:connection];
}


- (void)cancelConnections {
    [self.connectionQueue setSuspended:YES];
    [self.connectionQueue cancelAllOperations];
    [self.connectionQueue addOperationWithBlock:^{
        for (ServerURLConnection *connection in self.connections) {
            NSLog(@"Canceling Connection:%@",connection);
            [connection cancel];
            connection.ServerError([NSError errorWithDomain:[[NSBundle mainBundle]bundleIdentifier] code:-2 userInfo:@{NSLocalizedDescriptionKey: @" canceled by user"}]);
        }
        [self.connections removeAllObjects];
    }];
    [self.connectionQueue setSuspended:NO];
}


-(void)setBasicHeaders:(NSString*)header{
    self.authHeader = [ NSString stringWithFormat:@"Basic %@",header];
}



-(void)postRequestWithData{
    if(!self.URL){
        return;
    }
    
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    
    // set as POST request
    request.HTTPMethod = @"POST";
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }
    // Convert data and set request's HTTPBody property
    [request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    self.response = response;
    self.error = error;
}


-(NSData*)getRequest{
    if(!self.URL){
        return nil;
    }
    
    NSError* error = nil;
    NSURLResponse* response = nil;
        
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
        
    // set as GET request
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }
        
    // Convert data and set request's HTTPBody property
    [request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    self.response = response;

    if(error){
        self.error = error;
        return nil;
    }
    
    return data;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    ServerURLConnection *serverConnection = (ServerURLConnection *)connection;
    serverConnection.ServerError(error);
    [self.connections removeObject:serverConnection];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod
			isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod
		 isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		if ([self promptForCertTrust:challenge])
		{
			NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
		}
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(BOOL)promptForCertTrust:(NSURLAuthenticationChallenge *)challenge{
    SecTrustRef trust = [[challenge protectionSpace ]serverTrust];

    SecTrustResultType result;
    SecTrustEvaluate(trust, &result);
    
    NSLog(@"Challenge Results: %d",result);
    
    if(result == kSecTrustResultProceed){
        return YES;
    }
    
    else if(result == kSecTrustResultRecoverableTrustFailure){
        SFCertificateTrustPanel *panel = [SFCertificateTrustPanel sharedCertificateTrustPanel];
        [panel setAlternateButtonTitle:@"Cancel"];
        [panel setInformativeText:@"The server is offering a certificate that doesn't match.  You may be putting your info at risk, if you would like to trust this server anyway?"];
        
        NSInteger button = [panel runModalForTrust:trust message:@"Certificate Mismatch"];
        panel = nil;
        return button;
    }
    return NO;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    ServerURLConnection *con = (ServerURLConnection *)connection;
    con.response = response;
    con.data.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    ServerURLConnection *con = (ServerURLConnection *)connection;
    [con.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.connections removeObject:connection];
    ServerURLConnection *con = (ServerURLConnection *)connection;
    
    if ([con.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)con.response;
        if (response.statusCode >= 400){
            con.ServerError([NSError errorWithDomain:@"Server" code:response.statusCode
                                            userInfo:@{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]}]);
            return;
        }
    }
    
    con.ServerData(con.data);
}



#pragma mark - Test
+(BOOL)checkURL:(NSString*)url{
    BOOL rc = YES;
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // set as GET request
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSInteger server_rc = [((NSHTTPURLResponse *)response) statusCode];
    
    if(server_rc >= 400 || error){
        rc = NO;
    }
    return rc;
}

@end
