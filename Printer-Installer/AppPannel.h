//
//  AppProgress.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface AppPannel : NSObject

@property (assign) IBOutlet NSPanel *defaultsPanel;
@property (assign) IBOutlet NSButton *defaultsOKButton;
@property (assign) IBOutlet NSTextField *defaultsServerName;


- (void)startDefaultsPanel:(NSString*)message;

+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window;
+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector;

+ (void)setupDidEndWithTerminalError:(NSAlert *)alert;
+ (void)showErrorAlert:(NSError *)error;

@end