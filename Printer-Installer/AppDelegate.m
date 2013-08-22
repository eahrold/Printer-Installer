//
//  AppDelegate.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
NSError* initError;

@synthesize window;

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
        [self addPrinter:printer];
    }else if([value integerValue] == 0 ){
        [self removePrinter:printer];
    }
    
    [tableView reloadData];
}

//-------------------------------------------
//  NSXPC Methods
//-------------------------------------------

-(void)addPrinter:(Printer*)printer{
    NSLog(@"Adding printer: %@",printer.description);
    
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxy] addPrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [self showErrorAlert:error];
             }
         }];
         [helperXPCConnection invalidate];
     }];
}

-(void)removePrinter:(Printer*)printer{
    NSLog(@"Removing printer: %@",printer.description);
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    
    [helperXPCConnection resume];
    [[helperXPCConnection remoteObjectProxy] removePrinter:printer withReply:^(NSError *error)
     {
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             if(error){
                 NSLog(@"%@",[error localizedDescription]);
                 [self showErrorAlert:error];

             }
         }];
         [helperXPCConnection invalidate];
     }];
}

-(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] quitHelper];
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

//-------------------------------------------
//  Set Up Arrays
//-------------------------------------------

-(void)setPrinterList{
    NSUserDefaults *getDefaults = [NSUserDefaults standardUserDefaults];

    Server* server = [Server new];
    server.URL = [getDefaults objectForKey:@"server"];
    [server setGetListPath];
    
    printerList = [[server getRequest] objectForKey:@"printerList"];

    if(server.error){
        initError = server.error;
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


-(void)setDefaults{
    NSUserDefaults* setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setObject:printerList forKey:@"printerList"];
    [setDefaults synchronize];
}


//-------------------------------------------
//  Progress Panel and Alert
//-------------------------------------------

- (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}


- (void)showErrorAlert:(NSError *)error withSelector:(SEL)selector{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window
                                               modalDelegate:self
                                              didEndSelector:selector
                                                 contextInfo:nil];
}


- (void)setupDidEndWithTerminalError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
    [NSApp terminate:self];
}

//-------------------------------------------
//  Delegate Methods
//-------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if(initError){
        [self showErrorAlert:initError withSelector:@selector(setupDidEndWithTerminalError:)];
    }
    
    // Insert code here to initialize your application
    NSError  *error = nil;
    NSString *prompt = @"In order to User the SMC Printers";
    
    if ([JobBlesser helperNeedsInstalling]){
        BOOL rc = [JobBlesser blessHelperWithLabel:kHelperName andPrompt:prompt error:&error];
        
        if(rc){
            NSLog(@"Helper Tool Installed");
        }else{
            NSLog(@"Somthing went wrong %d",rc);
            // [self showErrorAlert:error withSelector:@selector(setupDidEndWithTerminalError:)];
        }
    }
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [self tellHelperToQuit];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

@end
