//
//  PIBonjourBrowser.m
//  Printer-Installer
//
//  Created by Eldon on 1/15/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import "PIBonjourBrowser.h"
#import "OCPrinter.h"

@interface OCPrinter (initWithServiceDiscovery)
-(id)initWithServiceDiscovery:(NSNetService*)sender;
@end

@implementation PIBonjourBrowser

- (id)init
{
    self = [super init];
    if (self) {
        _services = [NSMutableArray arrayWithCapacity: 0];
        _searching = NO;
    }
    return self;
}

-(id)initWithDelegate:(id<PIBonjourBrowserDelegate>)delegate{
    self = [self init];
    if(self){
        _delegate=delegate;
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing
{
    [_services addObject:service];
    [service setDelegate:self];
    [service startMonitoring];
    [service resolveWithTimeout:1];
    if(!moreComing)
    {
        //[self updateUI];
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    _searching = YES;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    _searching = NO;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    _searching = NO;
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}



- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)service
               moreComing:(BOOL)moreComing
{
    [_delegate removeBonjourPrinter:[service name]];
    [_services removeObject:service];
    
    if(!moreComing)
    {
        
    }
}

- (void)handleError:(NSNumber *)error
{
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
}


-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    NSDictionary *dict = [sender readableTXTRecord];
    if(dict){
        OCPrinter *printer = [[OCPrinter alloc]initWithServiceDiscovery:sender];
        [_delegate addBonjourPrinter:printer];
        [sender stop];
    }
}

-(void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data{
}

@end

#pragma mark - Readable Record from NSNetService
@implementation NSNetService (readableTXTRecord)
-(NSDictionary*)readableTXTRecord{
    NSData* data = [self TXTRecordData];
    NSDictionary* dict =[NSNetService dictionaryFromTXTRecordData:data];
    NSMutableDictionary* retDict = [[NSMutableDictionary alloc]initWithCapacity:dict.count+3];
    [retDict setObject:[self.name stringByReplacingOccurrencesOfString:@" " withString:@"_"] forKey:@"name"];
    [retDict setObject:[self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"host"];

    [retDict setObject:self.name forKey:@"description"];
    for(id i in dict){
        NSString* str = [[NSString alloc]initWithData:[dict valueForKey:i] encoding:NSASCIIStringEncoding];
        [retDict setValue:str forKey:i];
    }
    return retDict;
}
@end

#pragma mark Printer Extension for NSNetService
@implementation OCPrinter (initWithServiceDiscovery)
-(id)initWithServiceDiscovery:(NSNetService*)sender{
    NSDictionary* dict = [sender readableTXTRecord];
    self = [super init];
    if(self){
        self.name =         dict[@"name"];
        self.description =  dict[@"description"];
        self.host =         dict[@"host"];
        self.model =        dict[@"ty"];
        self.protocol =     @"dnssd";
    }
    return self;
}

@end
