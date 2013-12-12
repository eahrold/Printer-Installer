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

@implementation helper


-(void)addPrinter:(Printer *)printer withReply:(void (^)(NSError *))reply{
    [printer addPrinter];
    reply(printer.error);
}


-(void)removePrinter:(Printer *)printer withReply:(void (^)(NSError *))reply{
    [printer removePrinter];
    reply(printer.error);
}

-(void)quitHelper{
    // this will cause the run-loop to exit;
    // you should call it via NSXPCConnection during the applicationShouldTerminate routine
    self.helperToolShouldQuit = YES;
}

-(void)helperInstallLoginItem:(NSURL*)loginItem{
    syslog(1,"installing loginitem");
    AuthorizationRef auth = NULL;
    LSSharedFileListRef globalLoginItems = LSSharedFileListCreate(NULL, kLSSharedFileListGlobalLoginItems, NULL);
    LSSharedFileListSetAuthorization(globalLoginItems, auth);
    
    if (globalLoginItems) {
        LSSharedFileListItemRef ourLoginItem = LSSharedFileListInsertItemURL(globalLoginItems,
                                                                             kLSSharedFileListItemLast,
                                                                             NULL, NULL,
                                                                             (__bridge CFURLRef)loginItem,
                                                                             NULL, NULL);
        if (ourLoginItem) {
            CFRelease(ourLoginItem);
        } else {
            syslog(1,"Could not insert ourselves as a global login item");
        }
        
        CFRelease(globalLoginItems);
    } else {
        syslog(1,"Could not get the global login items");
    }
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

@end
