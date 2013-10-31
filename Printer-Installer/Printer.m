//
//  Printer.m
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Printer.h"
#import <syslog.h>

@implementation Printer


-(void)setPrinterFromDictionary:(NSDictionary*)dict{
    self.name = [dict objectForKey:@"printer"];
    self.location = [dict objectForKey:@"location"];
    self.description = [dict objectForKey:@"description"];
    self.host = [dict objectForKey:@"url"];
    self.protocol = [dict objectForKey:@"protocol"];
    self.model = [dict objectForKey:@"model"];
    self.options = [NSArray arrayWithArray:[dict objectForKey:@"options"]];
    self.url = [ self getFullURL];
    
    
    // check if it's installed locally
    NSString* path = [NSString stringWithFormat:@"/Library/Printers/PPDs/Contents/Resources/%@.gz",self.model];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        self.ppd = path;
    }
    
    // if not local, try and get if from the printer-installer-server
    if(!self.ppd && [dict objectForKey:@"ppd"]){
        path = [[dict objectForKey:@"ppd"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        [self downloadPPD:[NSURL URLWithString:path]];
    }
    
    // otherwise, if it's getting shared via ipp, try to grab it from the CUPS server
    if(!self.ppd && [self.protocol isEqualToString:@"ipp"]){
        path = [NSString stringWithFormat:@"http://%@:631/printers/%@.ppd",self.host,self.name];
        [self downloadPPD:[NSURL URLWithString:path]];
    }
    
    // if we still don't have it error out
    if(!self.ppd){
        self.error = [NSError errorWithDomain:@"No PPD Avaliable"
                                         code:1
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"No PPD Avaliable, please download and install the drivers from the manufacturer.",NSLocalizedDescriptionKey,nil]];
    }
}


-(NSString*)getFullURL{
    NSString* url;
   
    if([self.protocol isEqualToString:@"ipp"]){
        url = [NSString stringWithFormat:@"%@://%@/printers/%@",self.protocol,self.host,self.name];
    }
    else if([self.protocol isEqualToString:@"http"] || [self.protocol isEqualToString:@"https"]) {
        url = [NSString stringWithFormat:@"%@://%@:631/printers/%@",self.protocol,self.host,self.name];
    }
    else if([self.protocol isEqualToString:@"socket"]){
        url = [NSString stringWithFormat:@"%@://%@:9100",self.protocol,self.host];
    }
    else{
        url = [NSString stringWithFormat:@"%@://%@",self.protocol,self.host];
    }
    
    return url;
}

-(BOOL)downloadPPD:(NSURL*)URL{
    if(!URL){
        syslog(1, "the url %s isn't valid",[[URL path] UTF8String]);
        return NO;
    }
    syslog(1, "downloading from %s",[[URL path] UTF8String]);

    BOOL success = YES;
    
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    // set as GET request
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString* downloadedPPD = [NSTemporaryDirectory() stringByAppendingPathComponent:self.name];
    
    NSInteger rc = [((NSHTTPURLResponse *)response) statusCode];
    
    if(rc == 404 || rc == 500){
        NSDictionary* d = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"Server returned a %ld error",(long)rc],@"forKey:NSLocalizedDescriptionKey",nil ];
        error = [NSError errorWithDomain:@"Web Server" code:rc userInfo:d];
    }
    
    if(error){
        syslog(1,"%s",[error.localizedDescription UTF8String]);
        success = NO;
    }else{
        if([[NSFileManager defaultManager] createFileAtPath:downloadedPPD contents:data attributes:nil]){
            self.ppd = downloadedPPD;
            syslog(1,"%s",[error.localizedDescription UTF8String]);
        }else{
            
        }
    }
    return success;
}

@end
