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
                                                  action:@selector(showAboutPanel)
                                           keyEquivalent:@""];
    [about setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [about setTarget:[NSApp delegate]];
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
    
    NSSet* set = [Printer getInstalledPrinters];
    NSArray* printerList = [delegate printersInPrinterList:self];
    NSMutableSet * cmp = [[NSMutableSet alloc]init];
    
    if(printerList.count){
        for (NSMenuItem* i in currentManagedPrinters){
            [self removeItem:i];
        }
        
        for ( NSDictionary* dict in [[printerList reverseObjectEnumerator] allObjects]){
            Printer* printer = [[Printer alloc]initWithDictionary:dict];
            
            if(printer){
                NSMenuItem* smi;
                if(printer.description){
                    smi = [[NSMenuItem alloc]initWithTitle:printer.description
                                                    action:@selector(managePrinter:)
                                             keyEquivalent:@""];
                }else{
                    smi = [[NSMenuItem alloc]initWithTitle:printer.name
                                                    action:@selector(managePrinter:)
                                             keyEquivalent:@""];
                }
                
                [smi setTarget:delegate];
                NSMenu* details = [[NSMenu alloc]init];
                
                if(![printer.location isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"location: %@",printer.location] action:nil keyEquivalent:@""];
                if(![printer.model isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"model: %@",printer.model] action:nil keyEquivalent:@""];
                if(![printer.ppd_url isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"ppd: %@",printer.ppd_url] action:nil keyEquivalent:@""];
                
                [details addItemWithTitle:printer.url action:nil keyEquivalent:@""];
                
                [self setSubmenu:details forItem:smi];
                [self insertItem:smi atIndex:3];
                [cmp addObject:smi];
                
                if([set containsObject:printer.name]){
                    [smi setState:NSOnState];
                }else{
                    [smi setState:NSOffState];
                }
            }
            currentManagedPrinters = [NSSet setWithSet:cmp];
        }
    }
}

@end
