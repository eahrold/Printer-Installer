//
//  AppProgress.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppProgress : NSObject

+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window;
+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector;

+ (void)setupDidEndWithTerminalError:(NSAlert *)alert;

@end
