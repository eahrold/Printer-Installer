//
//  PIConfigView.h
//  Printer-Installer
//
//  Created by Eldon on 12/10/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PIError.h"

@protocol PIConfigViewControllerDelegate <NSObject>
- (void)refreshPrinterList;
- (void)cancelConfigView;
- (BOOL)installLoginItem:(BOOL)state;
@end

@interface PIConfigView : NSViewController
@property (weak) id<PIConfigViewControllerDelegate>delegate;

@property (assign) IBOutlet NSButton *defaultsCancelButton;
@property (assign) NSString *panelMessage;  // <----     this is bound

@end
