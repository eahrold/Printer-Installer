//
//  PILoginItem.m
//  Printer-Installer
//
//  Created by Eldon on 11/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PILoginItem.h"
#import "PIError.h"

@implementation PILoginItem

+(BOOL)installLoginItem:(BOOL)state{
    BOOL status = YES;
    NSError* error;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef loginItem = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if(state){
        //Adding Login Item
        if (loginItems) {
            LSSharedFileListItemRef ourLoginItem = LSSharedFileListInsertItemURL(loginItems,
                                                                                 kLSSharedFileListItemLast,
                                                                                 NULL, NULL,
                                                                                 loginItem,
                                                                                 NULL, NULL);
            if (ourLoginItem) {
                CFRelease(ourLoginItem);
            } else {
                status = [PIError errorWithCode:kPIErrorCouldNotAddLoginItem error:&error];
            }
            CFRelease(loginItems);
        } else {
            status = [PIError errorWithCode:kPIErrorCouldNotAddLoginItem error:&error];
        }
        if(error)
            [PIError presentError:error];
        
    }else{
        //Removing Login Item
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
            }
        }
        CFRelease(loginItems);
    }
    return status;
}


@end
