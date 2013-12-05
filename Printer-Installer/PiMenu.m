//
//  PIStatusBar.m
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Sparkle/SUUpdater.h>
#import "PIMenu.h"

@implementation PIMenu{
    NSSet* currentManagedPrinters;
    BOOL setupDone;
}
@synthesize delegate;

-(void)awakeFromNib{
    // Setup About Panel As Alternate Key
    NSMenuItem* about = [[NSMenuItem alloc]initWithTitle:@"About..."
                                                  action:@selector(orderFrontStandardAboutPanel:)
                                           keyEquivalent:@""];
    [about setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [about setTarget:[NSApplication sharedApplication]];
    [about setAlternate:YES];
    [self insertItem:about atIndex:1];
}

-(void)updateMenuItems{
    if(!setupDone){
        // Setup Uninstall Helper as Alternate Menu Item...
        NSMenuItem* uninstall = [[NSMenuItem alloc]initWithTitle:@"Uninstall..."
                                                          action:@selector(uninstallHelper:)
                                                   keyEquivalent:@""];
        [uninstall setKeyEquivalentModifierMask:NSAlternateKeyMask];
        [uninstall setTarget:delegate];
        [uninstall setAlternate:YES];
        [self insertItem:uninstall atIndex:[self numberOfItems]];
        setupDone = YES;
    }
    
    NSSet* set = [PICups getInstalledPrinters];
    NSArray* printerList = [delegate printersInPrinterList:self];
    NSMutableSet * cmp = [[NSMutableSet alloc]init];
    
    if(printerList.count){
        for (NSMenuItem* i in currentManagedPrinters){
            [self removeItem:i];
        }
        
        for ( NSDictionary* dict in [[printerList reverseObjectEnumerator] allObjects]){
            Printer* p = [[Printer alloc]initWithDict:dict];
            
            if(!p.error){
                NSMenuItem* smi;
                if(p.description){
                    smi = [[NSMenuItem alloc]initWithTitle:p.description
                                                    action:@selector(managePrinter:)
                                             keyEquivalent:@""];
                }else{
                    smi = [[NSMenuItem alloc]initWithTitle:p.name
                                                    action:@selector(managePrinter:)
                                             keyEquivalent:@""];
                }
                
                [smi setTarget:delegate];
                NSMenu* details = [[NSMenu alloc]init];
                
                if(![p.location isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"location: %@",p.location] action:nil keyEquivalent:@""];
                if(![p.model isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"model: %@",p.model] action:nil keyEquivalent:@""];
                if(![p.ppd_url isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"ppd: %@",p.ppd_url] action:nil keyEquivalent:@""];
                
                [details addItemWithTitle:p.url action:nil keyEquivalent:@""];
                
                [self setSubmenu:details forItem:smi];
                [self insertItem:smi atIndex:3];
                [cmp addObject:smi];
                
                if([set containsObject:p.name]){
                    [smi setState:NSOnState];
                }else{
                    [smi setState:NSOffState];
                }
            }else{
                NSLog(@"printer %@: %@",p.name,p.error.localizedDescription);
            }
            currentManagedPrinters = [NSSet setWithSet:cmp];
        }
    }
}

@end
