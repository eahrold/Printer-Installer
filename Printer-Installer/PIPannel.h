//
//  PIProgress.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>


@interface PIPannel : NSObject{
      
}

//@property (assign) IBOutlet NSWindow* configSheet;


+ (void)showErrorAlert:(NSError *)error;
+ (void)showErrorAlert:(NSError *)error withSelector:(SEL)selector;
+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window;
+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector;

+ (void)setupDidEndWithTerminalError:(NSAlert *)alert;



@end
