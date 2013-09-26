//
//  PITable.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PITable.h"

@implementation PITable

NSError* _error;

- (id)init {
    self = [super init];
    if (self) {
        [self setPrinterList];
    }
    
    return self;
}

//-------------------------------------------
//  Table Delegate
//-------------------------------------------

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [name count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualTo:@"name"]) {
        return [name objectAtIndex:row];
    }
    
    if ([[tableColumn identifier] isEqualTo:@"model"]) {
        return [model objectAtIndex:row];
    }
    
    else if ([[tableColumn identifier] isEqualTo:@"check"]) {
        return [state objectAtIndex:row];
    }
    
    else if ([[tableColumn identifier] isEqualTo:@"location"]) {
        return [location objectAtIndex:row];
    }
    
    return 0;
    
    
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    
    [state replaceObjectAtIndex:row withObject:value];
    
    Printer* printer = [Printer new];
    [printer setPrinterFromDictionary:[printerList objectAtIndex:row]];
        
    if([value integerValue] == 1 ){
        [PINSXPC addPrinter:[printerList objectAtIndex:row]];
    }else if([value integerValue] == 0 ){
        [PINSXPC removePrinter:[printerList objectAtIndex:row]];
    }
    
    [tableView reloadData];
}

-(void)setPrinterList{
    self.panelMessage = @"Please enter the Server address:";

    name = [NSMutableArray new];
    state = [NSMutableArray new];
    location = [NSMutableArray new];
    model = [NSMutableArray new];

    
    NSUserDefaults *getDefaults = [NSUserDefaults standardUserDefaults];
    NSString* sn = [getDefaults objectForKey:@"server"];
    
    if(!sn){
        [self performSelector: @selector(startDefaultsPanel:) withObject:self afterDelay: 0.1];
    }else{
        Server* server = [Server new];
        server.URL = sn;
        [server setGetListPath];
        [server setBasicHeaders:[getDefaults objectForKey:@"authHeader"]];
        
        printerList = [[server getRequest] objectForKey:@"printerList"];
        
        if(printerList.count == 0){
            [self.defaultsQuitButton setHidden:FALSE];
            self.panelMessage = @"The URL you entered may not be correct, please try again :";
            [self performSelector: @selector(startDefaultsPanel:) withObject:self afterDelay: 0.0];
        }else{
        
            if(server.error){
                _error = server.error;
                return;
            }
            
            
            NSSet* set = [self getInstalledPrinters];
            
            for (NSDictionary* i in printerList){
                [name addObject:[i objectForKey:@"description"]];
                NSString* loc = [i objectForKey:@"location"];
                if(loc){
                    [location addObject:loc];
                }else{
                    [location addObject:@""];
                }
                
                NSString* mdl = [i objectForKey:@"model"];
                if(mdl){
                    [model addObject:mdl];
                }else{
                    [model addObject:@""];
                }
                
                
                if([set containsObject:[i objectForKey:@"printer"]]){
                    [state addObject:@"1"];
                }else{
                    [state addObject:@"0"];
                }
            }
        }
    }
    [self.printerTable reloadData];
}

//-------------------------------------------
//  Cups  Stuff
//-------------------------------------------


-(NSSet*)getInstalledPrinters{
    int i;
    NSMutableSet *set = [NSMutableSet new];
    
    cups_dest_t *dests, *dest;
    int num_dests = cupsGetDests(&dests);
    
    for (i = num_dests, dest = dests; i > 0; i --, dest ++)
    {
        [set addObject:[NSString stringWithFormat:@"%s",dest->name]];
    }
    
    return set;
}



- (IBAction)startDefaultsPanel:(id)sender{
    NSString* sn = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];
    if(sn){
        _defaultsServerName.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"server"];
    }
    
    [NSApp beginSheet:_defaultsPanel
       modalForWindow:[[NSApp delegate]window]
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
}

- (IBAction)endDefaultsPanel:(id)sender{
    [NSApp endSheet:self.defaultsPanel];
    NSUserDefaults* setDefaults = [NSUserDefaults standardUserDefaults];
    if(![_defaultsServerName.stringValue isEqualToString:@""]){
        [setDefaults setObject:_defaultsServerName.stringValue forKey:@"server"];
        [setDefaults synchronize];
        [self setPrinterList];
    }

    [self.defaultsPanel close];
    
}
- (IBAction)quitNow:(id)sender{
    [NSApp endSheet:self.defaultsPanel];
    [[NSApplication sharedApplication]terminate:self];
    
    
}

@end
