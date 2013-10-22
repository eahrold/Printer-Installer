//
//  PIStatusBar.m
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIStatusBar.h"

@implementation PIStatusBar
@synthesize statusMenu = _statusMenu,
            statusItem = _statusItem,
            printerList, currentManagedPrinters;

- (id)initPrinterMenu{
    self = [super init];
    if (self != nil)
    {
        _statusMenu = [[NSMenu alloc]init];
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength ];
        //[statusItem setTitle:@"PI"];
        [_statusItem setImage:[NSImage imageNamed:@"Status"]];
        [_statusItem setMenu:_statusMenu];
        [_statusItem setHighlightMode:YES];
        
        [_statusMenu addItemWithTitle:@"Configure" action:@selector(configure) keyEquivalent:@""];
        [_statusMenu addItem:[NSMenuItem separatorItem]];
        [_statusMenu addItem:[NSMenuItem separatorItem]];
        [_statusMenu addItemWithTitle:@"Quit" action:@selector(quitNow) keyEquivalent:@""];
    }
    return self;
}

-(void)RefreshPrinters{
    for (NSMenuItem* i in currentManagedPrinters){
        [_statusMenu removeItem:i];
    }
    
    NSUserDefaults *getDefaults = [NSUserDefaults standardUserDefaults];
    NSString* sn = [getDefaults objectForKey:@"server"];
    
    Server* server = [[Server alloc]initWithURL:sn];
    [server setBasicHeaders:[getDefaults objectForKey:@"authHeader"]];
    
    printerList = [[server getRequest] objectForKey:@"printerList"];
    
    NSSet* set = [PICups getInstalledPrinters];
    NSMutableSet * cmp = [NSMutableSet new];
    
    for ( NSDictionary* p in printerList){
        NSString* printer = [p objectForKey:@"printer"];
        NSString* description = [p objectForKey:@"description"];
        NSString* location = [p objectForKey:@"location"];
        NSString* model = [p objectForKey:@"model"];

        NSMenuItem* smi;
        if(description){
            smi = [[NSMenuItem alloc]initWithTitle:description
                                            action:@selector(managePrinter:)
                                            keyEquivalent:@""];
        }else{
            smi = [[NSMenuItem alloc]initWithTitle:printer
                                            action:@selector(managePrinter:)
                                            keyEquivalent:@""];
        }
        
        NSMenu* details = [[NSMenu alloc]init];
        
        if(location){
            [details addItemWithTitle:[NSString stringWithFormat:@"location: %@",location] action:nil keyEquivalent:@""];
        }
        
        if(model){
            [details addItemWithTitle:[NSString stringWithFormat:@"model: %@",model] action:nil keyEquivalent:@""];
        }
        
        
        [_statusMenu setSubmenu:details forItem:smi];

        [_statusMenu insertItem:smi atIndex:2];
        [cmp addObject:smi];
        
        if([set containsObject:printer]){
            [smi setState:NSOnState];
        }else{
            [smi setState:NSOffState];
        }        
    }
    currentManagedPrinters = [NSSet setWithSet:cmp];
}



@end
