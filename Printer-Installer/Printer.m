//
//  Printer.m
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Printer.h"

@implementation Printer


-(void)setPrinterFromDictionary:(NSDictionary*)dict{
    self.name = [dict objectForKey:@"printer"];
    self.location = [dict objectForKey:@"location"];
    self.description = [dict objectForKey:@"description"];
    self.host = [dict objectForKey:@"host"];
    self.protocol = [dict objectForKey:@"protocol"];
    self.model = [dict objectForKey:@"model"];
    self.options = [[NSArray alloc] initWithArray:[dict objectForKey:@"options"]];
    
    //self.ppd = [dict objectForKey:@"ppd"];
    
    /*use some private methods to do some conditional formatting*/
    if(!self.ppd){
        self.ppd = [self setPPDPath:self.model];
    }
    
    self.url = [ self getFullURL];
}

-(NSString*)setPPDPath:(NSString*)model{
    NSString* path = [NSString stringWithFormat:@"/Library/Printers/PPDs/Contents/Resources/%@.gz",model];
    return path;
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
@end
