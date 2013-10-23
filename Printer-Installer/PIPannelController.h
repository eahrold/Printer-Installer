//
//  PIProgress.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "PIDelegate.h"
#import "Helper-SMJobBless.h"

@interface PIPannelCotroller : NSObject

@property (assign) IBOutlet NSWindow* configSheet;
@property (assign) IBOutlet NSButton *defaultsSetButton;
@property (assign) IBOutlet NSButton *defaultsCancelButton;
@property (assign) NSString *panelMessage;  // <----     this is bound

- (IBAction)openConfigSheet:(id)sender;
- (IBAction)closeConfigSheet:(id)sender;
- (IBAction)launchAtLoginChecked:(id)sender;

+ (void)showErrorAlert:(NSError *)error;
+ (void)showErrorAlert:(NSError *)error withSelector:(SEL)selector;
+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window;
+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector;

+ (void)setupDidEndWithTerminalError:(NSAlert *)alert;


@end
