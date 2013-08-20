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
        
        [self setPrinterList];
    }
    return self;
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {    
    return [name count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualTo:@"name"]) {
        return [name objectAtIndex:row];
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

-(void)addPrinter:(Printer*)printer{
    NSLog(@"Adding printer: %@",printer.name);
    
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
    NSLog(@"Removing printer: %@",printer.name);
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

//-------------------------------------------
//  Cups  Stuff
//-------------------------------------------

-(NSSet*)getAddedPrinters{
   
    NSTask* task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/lpstat"];
    
    NSArray* args = [[NSArray alloc]initWithObjects:@"-a", nil];
    [task setArguments:args];
        
    NSPipe* outPipe = [NSPipe new];
    [task setStandardOutput:outPipe];
        
    [task launch];
    [task waitUntilExit];
    
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *list = [str componentsSeparatedByString:@"\n"];

    NSMutableSet *set = [NSMutableSet new];
    
    for(NSString* i in list){
        NSArray *p = [i componentsSeparatedByString:@" "];
        [set addObject:[p objectAtIndex:0]];
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
    
    
    NSSet* set = [self getAddedPrinters];
    
    for (NSDictionary* i in printerList){
        [name addObject:[i objectForKey:@"description"]];
        
        NSString* loc = [i objectForKey:@"location"];
        if(loc){
            [location addObject:loc];
        }else{
            [location addObject:@""];
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
    NSError *error = nil;
    if ( [self helperNeedsInstalling] && ![self blessHelperWithLabel:kHelperName error:&error] ){
        NSLog(@"Something went wrong!");
    }
//    else{
//        NSLog(@"Helper installed & available.");
//    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}


-(void)applicationWillTerminate:(NSNotification *)notification{
    //finalize things
    //[self setDefaults];
    [self tellHelperToQuit];
}



//----------------------------------------------
//  SMJobBless
//----------------------------------------------

- (BOOL)blessHelperWithLabel:(NSString *)label
                       error:(NSError **)error {
    
    OSStatus result;
    
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags authFlags		=	kAuthorizationFlagDefaults				|
    kAuthorizationFlagInteractionAllowed	|
    kAuthorizationFlagPreAuthorize			|
    kAuthorizationFlagExtendRights;
    
	AuthorizationRef authRef = NULL;
	
    result = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, authFlags, &authRef);
	if (result != errAuthorizationSuccess) {
        NSLog(@"Failed to create AuthorizationRef. Error code: %d", result);
        
	} else {
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)CFBridgingRetain(label), authRef, (CFErrorRef *)nil);
	}
    
	AuthorizationFree (authRef, kAuthorizationFlagDefaults);
	return result;
}


-(BOOL)helperNeedsInstalling{
    //This dose the job of checking wether the Helper App needs updateing,
    //Much of this was taken from Eric Gorr's adaptation of SMJobBless http://ericgorr.net/cocoadev/SMJobBless.zip
    OSStatus result = YES;
    
    

    NSDictionary* installedHelperJobData = (NSDictionary*)CFBridgingRelease(SMJobCopyDictionary( kSMDomainSystemLaunchd, (CFStringRef)kHelperName ));
    
    if ( installedHelperJobData ){
        NSString* installedPath = [[installedHelperJobData objectForKey:@"ProgramArguments"] objectAtIndex:0];
        NSURL* installedPathURL = [NSURL fileURLWithPath:installedPath];
        NSDictionary* installedInfoPlist = (NSDictionary*)CFBridgingRelease(CFBundleCopyInfoDictionaryForURL( (CFURLRef)CFBridgingRetain(installedPathURL) ));
        NSString* installedBundleVersion = [installedInfoPlist objectForKey:@"CFBundleVersion"];
        
        //NSLog( @"Currently installed helper version: %@", installedBundleVersion );
        
        
        // Now we'll get the version of the helper that is inside of the Main App's bundle
        NSString * wrapperPath = [NSString stringWithFormat:@"Contents/Library/LaunchServices/%@",kHelperName];
        
        NSBundle* appBundle = [NSBundle mainBundle];
        NSURL* appBundleURL	= [appBundle bundleURL];
        NSURL* currentHelperToolURL	= [appBundleURL URLByAppendingPathComponent:wrapperPath];
        NSDictionary* currentInfoPlist = (NSDictionary*)CFBridgingRelease(CFBundleCopyInfoDictionaryForURL( (CFURLRef)CFBridgingRetain(currentHelperToolURL) ));
        NSString* currentBundleVersion = [currentInfoPlist objectForKey:@"CFBundleVersion"];
        
        //NSLog( @"Avaliable helper version: %@", currentBundleVersion );
        
        
        // Compare the Version numbers -- This could be done much better...
        if ([installedBundleVersion compare:currentBundleVersion options:NSNumericSearch] == NSOrderedDescending
            || [installedBundleVersion isEqualToString:currentBundleVersion]) {
            //NSLog(@"Current version of Helper App installed");
            result = NO;
        }
	}
    return result;
}

-(void)tellHelperToQuit{
    // Send a message to the helper tool telling it to call it's quitHelper method.
    NSXPCConnection *helperXPCConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperName options:NSXPCConnectionPrivileged];
    
    helperXPCConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    [helperXPCConnection resume];
    
    [[helperXPCConnection remoteObjectProxy] quitHelper];
}

@end
