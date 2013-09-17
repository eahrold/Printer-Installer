//
//  PITable.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <cups/cups.h>

#import "Server.h"
#import "PINSXPC.h"
#import "PIPannel.h"


@interface PITable : NSObject <NSTableViewDelegate, NSTableViewDataSource>{
    
    NSMutableArray *name;
    NSMutableArray *location;
    NSMutableArray *state;
    NSMutableArray *model;
    
    NSArray* printerList;
    

}
@property (assign) IBOutlet NSTableView *printerTable;
@property (assign) NSString *panelMessage;  // <----     this is bound

@property (assign) IBOutlet NSWindow *defaultsPanel;
@property (assign) IBOutlet NSButton *defaultsSetButton;
@property (assign) IBOutlet NSButton *defaultsQuitButton;

@property (assign) IBOutlet NSTextField *defaultsServerName;

- (IBAction)startDefaultsPanel:(id)sender;
- (IBAction)endDefaultsPanel:(id)sender;
- (IBAction)quitNow:(id)sender;


@end
