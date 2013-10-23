//
//  PIDelegate.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

#import "Helper-SMJobBless.h"
#import "PINSXPC.h"
#import "PIPannelController.h"
#import "PIStatusBar.h"

@interface PIDelegate : NSObject <NSApplicationDelegate>{
    NSArray* printerList;
}

@property (strong, nonatomic) PIStatusBar* piBar;
@property (assign) IBOutlet NSButton *defaultsSetButton;

@end
