//
//  Printer.m
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Printer.h"
#import "PIError.h"
#import <syslog.h>

@implementation Printer

-(id)initWithDict:(NSDictionary*)dict{
    self = [super init];
    if(self){
        [self setValuesForKeysWithDictionary:dict];
        [self configureURL];
    }
    return self;
}

-(void)configureURL{
    // ipp and ipps for connecting to CUPS server
    if([_protocol isEqualToString:@"ipp"]||[_protocol isEqualToString:@"ipps"]){
        _url = [NSString stringWithFormat:@"%@://%@/printers/%@",_protocol,_host,_name];
    }
    // http and https for connecting to CUPS server
    else if([_protocol isEqualToString:@"http"] || [_protocol isEqualToString:@"https"]){
        _url = [NSString stringWithFormat:@"%@://%@:631/printers/%@",_protocol,_host,_name];
    }
    // socket for connecting to AppSocket 
    else if([_protocol isEqualToString:@"socket"]){
        _url = [NSString stringWithFormat:@"%@://%@:9100",_protocol,_host];
    }
    else if([_protocol isEqualToString:@"lpd"]){
        _url = [NSString stringWithFormat:@"%@://%@",_protocol,_host];
    }
    else if([_protocol isEqualToString:@"smb"]){
        _url = [NSString stringWithFormat:@"%@://%@/%@",_protocol,_host,_name];
    }
    else{
        _error = [PIError errorWithCode:PIInvalidProtocol];
    }
}

-(void)configurePPD{
    // check if we have the PPD locally
    NSString* path = [NSString stringWithFormat:@"/Library/Printers/PPDs/Contents/Resources/%@.gz",_model];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        _ppd = path;
    }
    
    // if not local, try and get if from the printer-installer-server
    if(!_ppd && ![_ppd_url isEqualToString:@""]){
        path = [_ppd_url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        _ppd = [self downloadPPD:[NSURL URLWithString:path]];
    }
    
    // otherwise, if it's getting shared via ipp, try to grab it from the CUPS server
    if(!_ppd && [_protocol isEqualToString:@"ipp"]){
        path = [NSString stringWithFormat:@"http://%@:631/printers/%@.ppd",_host,_name];
        _ppd = [self downloadPPD:[NSURL URLWithString:path]];
    }
    
    // if we still don't have it error out
    if(!_ppd){
        _error = [PIError errorWithCode:PIPPDNotFound];
    }

}

-(NSString*)downloadPPD:(NSURL*)URL{
    NSString* ppdFile;
    if(!URL){
        syslog(1, "the url %s isn't valid",[URL path].UTF8String);
        return nil;
    }
    
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
    NSString* downloadedPPD = [NSTemporaryDirectory() stringByAppendingPathComponent:_name];
    
    NSInteger rc = [((NSHTTPURLResponse *)response) statusCode];
    
    if(rc >= 400){
        error = [PIError errorWithCode:PIServerNotFound];
    }
    
    if(error){
        syslog(1,"error: %s",[error.localizedDescription UTF8String]);
        ppdFile = nil;
    }else{
        if([[NSFileManager defaultManager] createFileAtPath:downloadedPPD contents:data attributes:nil]){
            ppdFile = downloadedPPD;
        }else{
            syslog(1,"there was a problem Creating the PPD File");
            ppdFile = nil;
        }
    }
    return ppdFile;
}

@end
