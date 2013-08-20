//
//  helper.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "helper.h"

@implementation helper

-(void)addPrinter:(Printer *)printer withReply:(void (^)(NSError *))reply{
    NSError* error = nil;
   
    NSTask* task = [NSTask new];
    [task setLaunchPath:@"/usr/sbin/lpadmin"];
    
    NSMutableArray* args = [NSMutableArray new];
    [args addObject:@"-p"];
    [args addObject:printer.name];
    [args addObject:@"-D"];
    [args addObject:printer.description];
    
    if(printer.location){
        [args addObject:@"-L"];
        [args addObject:printer.location];
    }
    
    [args addObject:@"-E"];
    [args addObject:@"-v"];
    [args addObject:printer.url];
    [args addObject:@"-P"];
    [args addObject:printer.ppd];
    //[args addObject:@"-m"];
    //[args addObject:printer.model];
    
    [task setArguments:args];
    
    [task launch];
    [task waitUntilExit];
    int rc = [task terminationStatus];
    
    if(rc != 0){
        error = [self taksError:@"There was a problem adding the printer"
                 withReturnCode:rc];
    }

    reply(error);
}

-(void)removePrinter:(Printer *)printer withReply:(void (^)(NSError *))reply{
    NSError* error = nil;
    NSLog(@"using helper to add printer");
    
    NSTask* task = [NSTask new];
    [task setLaunchPath:@"/usr/sbin/lpadmin"];
    [task setArguments:[NSArray arrayWithObjects:@"-x",printer.name, nil]];
    
    [task launch];
    [task waitUntilExit];

    int rc = [task terminationStatus];
    if(rc != 0){
        error = [self taksError:@"There was a problem adding the printer"
                 withReturnCode:rc];
    }
    
    reply(error);
}

-(void)quitHelper{
    // this will cause the run-loop to exit;
    // you should call it via NSXPCConnection during the applicationShouldTerminate routine
    self.helperToolShouldQuit = YES;
}

//----------------------------------------
// Helper Singleton
//----------------------------------------
+ (helper *)sharedAgent {
    static dispatch_once_t onceToken;
    static helper *shared;
    dispatch_once(&onceToken, ^{
        shared = [helper new];
    });
    return shared;
}


//----------------------------------------
// Set up the one method of NSXPClistener
//----------------------------------------
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    newConnection.exportedObject = self;
    
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperProgress)];
    self.xpcConnection = newConnection;
    
    [newConnection resume];
    return YES;
}

-(NSError*)taksError:(NSString*)msg withReturnCode:(int)rc{
    NSString* m = [NSString stringWithFormat:@"%@.  Error Code: %d",msg,rc];
    NSError* error =[NSError errorWithDomain:NSPOSIXErrorDomain
                           code:rc
                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                 m,
                                 NSLocalizedDescriptionKey,
                                 nil]];
    return error;
}


@end
