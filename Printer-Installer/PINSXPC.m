//
//  PINSXPC.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PINSXPC.h"

@implementation PINSXPC

+(void)addPrinter:(NSDictionary*)printer{

    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxy] addPrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [PIPannelCotroller showErrorAlert:error onWindow:[[NSApplication sharedApplication]mainWindow]];
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

+(void)removePrinter:(NSDictionary*)printer{
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxy] removePrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [PIPannelCotroller showErrorAlert:error onWindow:[[NSApplication sharedApplication]mainWindow]];
                 
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

+(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] quitHelper];
}


@end
