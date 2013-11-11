//
//  PIProgress.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "PIError.h"

@protocol PIConfigSheetDelegate <NSObject>
- (void)setPrinterList;
- (void)cancelConfigSheet;
- (BOOL)installLoginItem:(BOOL)state;
@end

@interface PIConfigSheet : NSWindowController

@property (strong) id<PIConfigSheetDelegate>delegate;

@property (assign) IBOutlet NSButton *defaultsCancelButton;
@property (assign) NSString *panelMessage;  // <----     this is bound

@end
