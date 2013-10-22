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
#import "PIPannel.h"
#import "PIStatusBar.h"

@interface PIDelegate : NSObject <NSApplicationDelegate>{
    NSArray* printerList;
}

@property (strong, nonatomic) PIStatusBar* piBar;

@property (assign) NSString *panelMessage;  // <----     this is bound
@property (assign) BOOL launchOnLogin;  // <----     this is bound

@property (assign) IBOutlet NSWindow *defaultsPanel;
@property (assign) IBOutlet NSButton *defaultsSetButton;
@property (assign) IBOutlet NSButton *defaultsQuitButton;

@property (assign) IBOutlet NSTextField *defaultsServerName;

-(IBAction)startDefaultsPanel:(id)sender;
-(IBAction)endDefaultsPanel:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)launchAtLoginChecked:(id)sender;

@end
