//
//  helper.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//
// much of this is taken from lpadmin.c from CUPS.org source code
// http://www.cups.org/software.php?VERSION=1.6.2
// and I would like to acknowledge the excelent work
// of Matt Sweet and his team at cups.org

#import "helper.h"
#import <cups/cups.h>
#import <cups/ppd.h>

#import <syslog.h>

static const NSTimeInterval kHelperCheckInterval = 1.0; // how often to check whether to quit

@interface PIHelper()<HelperAgent,NSXPCListenerDelegate>
@property (atomic, strong, readwrite) NSXPCListener   *listener;
@property (weak) NSXPCConnection *connection;
@property (nonatomic, assign) BOOL helperToolShouldQuit;
@end

@implementation PIHelper

-(id)init{
    self = [super init];
    if(self){
        self->_listener = [[NSXPCListener alloc] initWithMachServiceName:kHelperName];
        self->_listener.delegate = self;
    }
    return self;
}

-(void)run{
    [self.listener resume];
    while (!self.helperToolShouldQuit)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:kHelperCheckInterval]];
    }
}


-(void)addPrinter:(Printer *)printer withReply:(void (^)(NSError *))reply{
    NSError *error;
    [printer addPrinter:&error];
    reply(error);
}


-(void)removePrinter:(Printer *)printer withReply:(void (^)(NSError *))reply{
    NSError *error;
    [printer removePrinter:&error];
    reply(error);
}

-(void)quitHelper:(void (^)(BOOL success))reply{
    // this will cause the run-loop to exit;
    // you should call it via NSXPCConnection
    // during the applicationShouldTerminate routine
    self.helperToolShouldQuit = YES;
    reply(YES);
}

-(void)uninstall:(void (^)(NSError *))reply{
    NSError* error;
    NSError* retunError;
    
    NSString *launchD = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist",kHelperName];
    NSString *helperTool = [NSString stringWithFormat:@"/Library/PrivilegedHelperTools/%@",kHelperName];
    
    [[NSFileManager defaultManager] removeItemAtPath:launchD error:&error];
    if (error.code != NSFileNoSuchFileError) {
        NSLog(@"%@", error);
        retunError = error;
        error = nil;
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:helperTool error:&error];
    if (error.code != NSFileNoSuchFileError) {
        NSLog(@"%@", error);
        retunError = error;
        error = nil;
    }
    reply(retunError);
    
}


//----------------------------------------
// Set up the one method of NSXPClistener
//----------------------------------------
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    
    newConnection.exportedObject = self;
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperProgress)];
    self.connection = newConnection;
    
    [newConnection resume];
    return YES;
}

@end
