//
//  helper.h
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Interfaces.h"

@interface helper : NSObject <HelperAgent,NSXPCListenerDelegate>

@property (nonatomic, assign) BOOL helperToolShouldQuit;

+ (helper *)sharedAgent;

@property (weak) NSXPCConnection *xpcConnection;

@end