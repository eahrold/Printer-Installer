//
//  PIMenu.m
//  Printer-Installer
//
//  Created by Eldon on 10/21/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Sparkle/SUUpdater.h>
#import "PIMenu.h"
#import <Objective-CUPS/Objective-CUPS.h>

#define PRINTER_MENU_INDEX 3

@implementation PIMenu{
    NSSet*      currentManagedPrinters;
    BOOL        setupDone;
    NSMenuItem* _bonjourMenuItem;
    NSMenu*     _bonjourMenu;
}

@synthesize delegate = _delegate;

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

#pragma mark - PIBonjourBrowserDelegate
-(BOOL)displayBonjourMenu:(BOOL)display{
    BOOL state = NO;
    if(display){
        if(!_bonjourMenu){
            _bonjourMenu = [[NSMenu alloc]initWithTitle:@"Bonjour Printers"];
        }
        if(!_bonjourMenuItem){
            _bonjourMenuItem = [[NSMenuItem alloc]init];
            _bonjourMenuItem.title = @"Bonjour Printers";
        }
        _bonjourMenuItem.submenu = _bonjourMenu;
        state = YES;
    }else if (_bonjourMenuItem){
        NSMenuItem* item =[ self itemWithTitle:_bonjourMenuItem.title];
        if(item)[self removeItem:_bonjourMenuItem];
        _bonjourMenu = nil;
        _bonjourMenuItem = nil;
        state =  NO;
    }
    return state;
}

-(void)addBonjourPrinter:(OCPrinter *)printer{
    if(!_bonjourMenu){
        if(![self displayBonjourMenu:YES])return;
    }
        
    if(![self itemWithTitle:_bonjourMenuItem.title]){
        NSInteger insertionPoint = [self indexOfItemWithTitle:@"Check For Updates..."];
        [self insertItem:_bonjourMenuItem atIndex:insertionPoint];
    };
    
    NSMenuItem* bpmi;
    if(printer.description){
        bpmi = [[NSMenuItem alloc]initWithTitle:printer.description
                                        action:@selector(manageBonjourPrinter:)
                                 keyEquivalent:@""];
    }else if(printer.name){
        bpmi = [[NSMenuItem alloc]initWithTitle:printer.name
                                        action:@selector(manageBonjourPrinter:)
                                 keyEquivalent:@""];
    }else{
        return;
    }
    
    [bpmi setTarget:self.delegate];
    NSMenu* details = [[NSMenu alloc]init];
    
    if(printer.location)
        [details addItemWithTitle:[NSString stringWithFormat:@"location: %@",printer.location] action:nil keyEquivalent:@""];
    
    if(printer.model)
        [details addItemWithTitle:[NSString stringWithFormat:@"model: %@",printer.model] action:nil keyEquivalent:@""];
    
    if(printer.ppd_url)
        [details addItemWithTitle:[NSString stringWithFormat:@"ppd: %@",printer.ppd_url] action:nil keyEquivalent:@""];
    
    if(printer.uri)
        [details addItemWithTitle:printer.uri action:nil keyEquivalent:@""];
    
    if([[OCManager installedPrinters] containsObject:printer.name]){
        [bpmi setState:NSOnState];
    }else{
        [bpmi setState:NSOffState];
    }
    
    [bpmi setSubmenu:details];
    [_bonjourMenu addItem:bpmi];
    if(!_delegate.bonjourPrinterList){
        _delegate.bonjourPrinterList = [NSMutableArray new];
    }
    [_delegate.bonjourPrinterList addObject:printer];
    
}

-(void)updateBonjourPrinter:(OCPrinter *)printer{
}

-(void)removeBonjourPrinter:(NSString *)printerName{
    NSMenuItem* item =[_bonjourMenu itemWithTitle:printerName];
    if(item)[_bonjourMenu removeItem:item];
    
    for(OCPrinter* p in _delegate.bonjourPrinterList ){
        if([p.description isEqualToString:printerName]){
            [_delegate.bonjourPrinterList removeObject:p];
            break;
        };
    }
    
    if(_delegate.bonjourPrinterList.count == 0){
        item = [self itemWithTitle:_bonjourMenuItem.title];
        if(item)[self removeItem:_bonjourMenuItem];
    }
}


-(void)updateMenuItems{
    if(!setupDone){
        // Setup Uninstall Helper as Alternate Menu Item...
        NSMenuItem* uninstall = [[NSMenuItem alloc]initWithTitle:@"Uninstall..."
                                                          action:@selector(uninstallHelper:)
                                                   keyEquivalent:@""];
        [uninstall setKeyEquivalentModifierMask:NSAlternateKeyMask];
        [uninstall setTarget:self.delegate];
        [uninstall setAlternate:YES];
        [self insertItem:uninstall atIndex:[self numberOfItems]];
        setupDone = YES;
    }
    NSSet* set;
    set = [OCManager installedPrinters];
    NSMutableSet * cmp = [[NSMutableSet alloc]init];
    if(_delegate.printerList.count){
        for (NSMenuItem* i in currentManagedPrinters){
            [self removeItem:i];
        }
        
        for ( NSDictionary* dict in [[_delegate.printerList reverseObjectEnumerator] allObjects]){
            OCPrinter* printer = [[OCPrinter alloc]initWithDictionary:dict];
            
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
                
                [smi setTarget:_delegate];
                NSMenu* details = [[NSMenu alloc]init];
                
                if(![printer.location isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"location: %@",printer.location] action:nil keyEquivalent:@""];
                if(![printer.model isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"model: %@",printer.model] action:nil keyEquivalent:@""];
                if(![printer.ppd_url isEqualToString:@""])[details addItemWithTitle:[NSString stringWithFormat:@"ppd: %@",printer.ppd_url] action:nil keyEquivalent:@""];
                
                [details addItemWithTitle:printer.uri action:nil keyEquivalent:@""];
                
                
                [self setSubmenu:details forItem:smi];
                [self insertItem:smi atIndex:PRINTER_MENU_INDEX];
                [cmp addObject:smi];
                
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == %@",printer.name];
                if( [[set filteredSetUsingPredicate:predicate] count] != 0){
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
