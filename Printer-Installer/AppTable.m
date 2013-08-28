//
//  AppTable.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/28/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppTable.h"

@implementation AppTable
NSError* _error;

- (id)init {
    self = [super init];
    if (self) {
        name = [NSMutableArray new];
        state = [NSMutableArray new];
        location = [NSMutableArray new];
        model = [NSMutableArray new];
        
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
        [AppNSXPC addPrinter:printer];
    }else if([value integerValue] == 0 ){
        [AppNSXPC removePrinter:printer];
    }
    
    [tableView reloadData];
}

-(void)setPrinterList{
    NSUserDefaults *getDefaults = [NSUserDefaults standardUserDefaults];
    
    Server* server = [Server new];
    server.URL = [getDefaults objectForKey:@"server"];
    [server setGetListPath];
    [server setBasicHeaders:[getDefaults objectForKey:@"authHeader"]];
    
    printerList = [[server getRequest] objectForKey:@"printerList"];
    
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

@end
