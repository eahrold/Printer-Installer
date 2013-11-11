//
//  PIProgress.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIPannelController.h"

@interface PIPannelCotroller ()

@end

static NSString * const kLoginHelper = @"edu.loyno.smc.Printer-Installer.loginlaunch";

@implementation PIPannelCotroller
@synthesize delegate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        self.panelMessage = @"Please enter the URL for the managed printers:";
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(IBAction)cancel:(id)sender{
    [delegate cancelConfigSheet];
}
-(IBAction)configure:(id)sender{
    [delegate setConfiguration];
}

//-------------------------------------------
//  Configure Sheet
//-------------------------------------------


-(IBAction)launchAtLoginChecked:(id)sender{
    NSButton* btn = sender;
    [self installLoginItem:btn.state];
}

-(void)installLoginItem:(BOOL)state{
//    NSArray  *loginItemsArray;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef loginItem = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);

    if(state){
        if (loginItems) {
            LSSharedFileListItemRef ourLoginItem = LSSharedFileListInsertItemURL(loginItems,
                                                                                 kLSSharedFileListItemLast,
                                                                                 NULL, NULL,
                                                                                 loginItem,
                                                                                 NULL, NULL);
            if (ourLoginItem) {
                CFRelease(ourLoginItem);
            } else {
                NSLog(@"Could not insert ourselves as a login item");
            }
            
            CFRelease(loginItems);
        } else {
            NSLog(@"Could not get the login items");
        }
    }else{
        if (loginItem){
            UInt32 seedValue;
            //Retrieve the list of Login Items and cast them to
            // a NSArray so that it will be easier to iterate.
            NSArray  *loginItemsArray = CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
            
            for( id i in loginItemsArray){
                LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)i;
                //Resolve the item with URL
                if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &loginItem, NULL) == noErr) {
                    NSString * urlPath = [(__bridge NSURL*)loginItem path];
                    if ([urlPath compare:appPath] == NSOrderedSame){
                        LSSharedFileListItemRemove(loginItems,itemRef);
                    }
                }
                CFRelease(loginItems);
            }
        }
    }
}

//-------------------------------------------
//  Progress Panel and Alert
//-------------------------------------------

+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:window
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

+ (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication]mainWindow]
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

+ (void)showErrorAlert:(NSError *)error withSelector:(SEL)selector{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication]mainWindow]
                                               modalDelegate:self
                                              didEndSelector:selector
                                                 contextInfo:nil];
}


+ (void)showErrorAlert:(NSError *)error onWindow:(NSWindow*)window withSelector:(SEL)selector{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:window
                                               modalDelegate:self
                                              didEndSelector:selector
                                                 contextInfo:nil];
}


+ (void)setupDidEndWithTerminalError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
    [NSApp terminate:self];
}


@end
