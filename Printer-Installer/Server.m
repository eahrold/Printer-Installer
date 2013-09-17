//
//  Server.m
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Server.h"

@implementation Server
-(void)setBasicHeaders:(NSString*)header{
    self.authHeader = [ NSString stringWithFormat:@"Basic %@",header];
}


-(void)setGetListPath{
    self.path =  [NSString stringWithFormat:@"%@.plist",self.URL];
}


-(void)postRequestWithData{        
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.path]];
    
    // set as POST request
    request.HTTPMethod = @"POST";
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    // Convert data and set request's HTTPBody property
    [request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    self.response = response;
    self.error = error;
}


-(NSDictionary*)getRequest{
    NSError* error = nil;
    NSURLResponse* response = nil;
        
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.path]];
        
    // set as GET request
    request.HTTPMethod = @"GET";
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    
    // Convert data and set request's HTTPBody property
    [request setHTTPBody:self.requestData];
    
    // Create url connection and fire request
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary* dict;
    self.response = response;
    self.error = error;
    
    if(error){
        return nil;
    }
    
    NSString* errorDesc = nil;
    NSPropertyListFormat plist;
    dict = (NSDictionary*)[NSPropertyListSerialization
                           propertyListFromData:data
                           mutabilityOption:NSPropertyListMutableContainersAndLeaves
                           format:&plist
                           errorDescription:&errorDesc];
    
    return dict;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)space {
    return YES;
}


@end
