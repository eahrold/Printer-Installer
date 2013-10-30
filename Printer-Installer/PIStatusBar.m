//
//  PIStatusBar.m
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIStatusBar.h"
#import <Sparkle/SUUpdater.h>

@implementation PIStatusBar

@synthesize statusMenu = _statusMenu;
@synthesize statusItem = _statusItem;
@synthesize printerList = _printerList;
@synthesize currentManagedPrinters = _currentManagedPrinters;

- (id)initPrinterMenu{
    self = [super init];
    if (self != nil)
    {
        _statusMenu = [[NSMenu alloc]init];
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength ];

        [_statusItem setMenu:_statusMenu];
        [_statusItem setImage:[NSImage imageNamed:@"StatusBar"]];
        [_statusItem setHighlightMode:YES];
        
        BOOL managed =[[NSUserDefaults standardUserDefaults]boolForKey:@"managed"];
        
        if(!managed){
            NSMenuItem *configure = [[NSMenuItem alloc]initWithTitle:@"Configure..." action:@selector(configure) keyEquivalent:@""];
            [configure setTarget:[NSApp delegate]];
            [_statusMenu addItem:configure];
        }else{
            [_statusMenu addItemWithTitle:@"Check Printer To Install" action:nil keyEquivalent:@""];
        }
        
        // add seperators for the printer list to go between
        [_statusMenu addItem:[NSMenuItem separatorItem]];
        [_statusMenu addItem:[NSMenuItem separatorItem]];
        
        if(![[[NSUserDefaults standardUserDefaults]objectForKey:@"SUFeedURLKey"]isEqualToString:@""] || !managed){
            NSMenuItem *cfu = [[NSMenuItem alloc]initWithTitle:@"Check For Updates..." action:@selector(checkForUpdates) keyEquivalent:@""];
            [cfu setTarget:self];
            [_statusMenu addItem:cfu];
        }
        
        NSMenuItem *quitMenu = [[NSMenuItem alloc]initWithTitle:@"Quit" action:@selector(quitNow) keyEquivalent:@""];
        [quitMenu setTarget:self];
        [_statusMenu addItem:quitMenu];

    }
    return self;
}

-(void)RefreshPrinters{
    NSUserDefaults *getDefaults = [NSUserDefaults standardUserDefaults];
    NSString* sn = [getDefaults objectForKey:@"server"];
      
    Server* server = [[Server alloc]initWithURL:sn];
    [server setBasicHeaders:[getDefaults objectForKey:@"authHeader"]];
    
    NSDictionary* piSettings = [server getRequest];
    NSString* feedURL = [piSettings objectForKey:@"updateServer"];
    
    _printerList = [piSettings objectForKey:@"printerList"];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] values]setValue:feedURL forKey:@"SUFeedURLKey"];
    
    //NSLog(@"feedURL: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"SUFeedURLKey"]);
    
    if(feedURL){
        [[SUUpdater sharedUpdater]setFeedURL:[NSURL URLWithString:feedURL]];
    }
    
    NSSet* set = [PICups getInstalledPrinters];
    NSMutableSet * cmp = [NSMutableSet new];
    
    if(_printerList.count != 0){
        for (NSMenuItem* i in _currentManagedPrinters){
            [_statusMenu removeItem:i];
        }

        for ( NSDictionary* p in [[_printerList reverseObjectEnumerator] allObjects]){
            NSString* printer = [p objectForKey:@"printer"];
            NSString* description = [p objectForKey:@"description"];
            NSString* location = [p objectForKey:@"location"];
            NSString* model = [p objectForKey:@"model"];
            NSString* ppd = [p objectForKey:@"ppd"];


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
            
            [smi setTarget:self];
            NSMenu* details = [[NSMenu alloc]init];
            
            if(location){
                [details addItemWithTitle:[NSString stringWithFormat:@"location: %@",location] action:nil keyEquivalent:@""];
            }
            
            if(model){
                [details addItemWithTitle:[NSString stringWithFormat:@"model: %@",model] action:nil keyEquivalent:@""];
            }
            
            if(ppd){
                [details addItemWithTitle:[NSString stringWithFormat:@"ppd: %@",ppd] action:nil keyEquivalent:@""];
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
        _currentManagedPrinters = [NSSet setWithSet:cmp];
    }
}

-(void)managePrinter:(id)sender{
    NSMenuItem* pmi = sender;
    NSInteger pix = ([self.statusMenu indexOfItem:pmi]-2);
    NSDictionary* printer = [self.printerList objectAtIndex:pix];
    
    [pmi setState:pmi.state ? NSOffState : NSOnState];
    if (pmi.state){
        [PINSXPC addPrinter:printer];
    }else{
        [PINSXPC removePrinter:printer];
    }

}

-(void)checkForUpdates{
    [[SUUpdater sharedUpdater] checkForUpdates:self];
}

-(void)quitNow{
    [NSApp terminate:self];
}

@end
