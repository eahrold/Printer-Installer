//
//  PINSXPC.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PINSXPC.h"
#import "PIAlert.h"
#import "Printer.h"

@implementation PINSXPC

#pragma mark - Initializers
-(id)initWithMachServiceName:(NSString *)name options:(NSXPCConnectionOptions)options{
    self = [super initWithMachServiceName:name options:options];
    if (self) {
        self.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
        [self resume];
    }
    return self;
}

-(id)initConnection{
    self = [self initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    return self;
}


-(void)addPrinter:(Printer*)printer reply:(void (^)(NSError* error))reply{
    [[self remoteObjectProxyWithErrorHandler:^(NSError *error) {
        if(error)[PIError presentError:error];
    }] addPrinter:printer withReply:^(NSError *error) {
        reply(error);
        [self invalidate];
    }];
}

-(void)removePrinter:(Printer*)printer reply:(void (^)(NSError* error))reply{
    [[self remoteObjectProxyWithErrorHandler:^(NSError *error) {
        if(error)[PIError presentError:error];
    }] removePrinter:printer withReply:^(NSError *error) {
        reply(error);
        [self invalidate];
    }];
}


+(void)changePrinterAvaliablily:(Printer*)printer add:(BOOL)added reply:(void (^)(NSError *error))reply{
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    if(added){
        [connection addPrinter:printer reply:^(NSError *error) {
            reply(error);
        }];
    }else{
        [connection removePrinter:printer reply:^(NSError *error) {
            reply(error);
        }];
    }
}

+(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    [[connection remoteObjectProxy] quitHelper:^(BOOL success) {
        [connection invalidate];
    }];
}

+(void)uninstallHelper{
    PINSXPC* connection = [[PINSXPC alloc]initConnection];
    [[connection remoteObjectProxy] uninstall:^(NSError * error) {
        [connection invalidate];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(error){
                [PIError presentError:error];
            }else{
                [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
                [PIAlert showAlertWithCode:kPIAlertHelperToolRemoved
                            didEndSelector:@selector(setupDidRemoveHelperTool:)];
            }
        }];
    }];
}


@end
