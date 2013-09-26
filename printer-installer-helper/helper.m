//
//  helper.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "helper.h"
#import <cups/cups.h>
#import <syslog.h>

@implementation helper

/* cups types */
ipp_t           *request;
cups_option_t	*options;

-(BOOL)addOptions:(Printer *)printer{
    const char* opt_details = [[NSString stringWithFormat:@"%@",printer.options] UTF8String];
    syslog(1,"setting options for printer %s",opt_details);

    NSTask* task = [NSTask new];
    NSMutableArray *args = [NSMutableArray new];
    
    [task setLaunchPath:@"/usr/sbin/lpadmin"];
    
    [args addObject:@"-p"];
    [args addObject:printer.name];
    
    for(NSString* opt in printer.options){
        [args addObject:@"-o"];
        [args addObject:opt];
    }
    
    [task setArguments:args];
    [task launch];
    [task waitUntilExit];
    
    return task.terminationStatus;
}

-(void)addPrinter:(NSDictionary *)printer withReply:(void (^)(NSError *))reply{
    NSError* error = nil;

    Printer* p = [Printer new];
    [p setPrinterFromDictionary:printer];
    
    syslog(1,"Adding printer %s",[p.name UTF8String]);

    
    char        uri[HTTP_MAX_URI];
    int         opt_count = 0;
    options = NULL;
    
    
    /* convert the printer obect items */
    const char  *name = [p.name UTF8String],
                *ppd = [p.ppd UTF8String],
                *device_url = [p.url UTF8String],
                *location = [p.location UTF8String],
                //*popts = [p.options UTF8String],
                *description = [p.description UTF8String];
    
    request = ippNewRequest(CUPS_ADD_MODIFY_PRINTER);

    if(location){
        opt_count = cupsAddOption("printer-location", location, opt_count, &options);
    }
    
    if(description){
        opt_count = cupsAddOption("printer-info", description, opt_count, &options);
    }
    
//    if(popts){
//        opt_count = cupsParseOptions(popts, opt_count, &options);
//    }
    
    opt_count = cupsAddOption("device-uri", device_url,
                              opt_count, &options);
    

    httpAssembleURIf(HTTP_URI_CODING_ALL, uri, sizeof(uri), "ipp", NULL,
                     "localhost", 0, "/printers/%s", name);
    
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_URI,
                 "printer-uri", NULL, uri);
    
    cupsEncodeOptions2(request, opt_count, options, IPP_TAG_PRINTER);

    ippAddInteger(request, IPP_TAG_PRINTER, IPP_TAG_ENUM, "printer-state",
                  IPP_PRINTER_IDLE);
    
    ippAddBoolean(request, IPP_TAG_PRINTER, "printer-is-accepting-jobs", 1);
    
    ippDelete(cupsDoFileRequest(CUPS_HTTP_DEFAULT, request, "/admin/", ppd));
    
    
    if (cupsLastError() > IPP_OK_CONFLICT)
    {
        error = [self cupsError:cupsLastErrorString()
                 withReturnCode:1];
    }
    
    if(p.options){
        [self addOptions:p];
    }
}

-(void)removePrinter:(NSDictionary *)printer withReply:(void (^)(NSError *))reply{
    Printer* p = [Printer new];
    [p setPrinterFromDictionary:printer];
    
    syslog(1,"Removing printer %s",[p.name UTF8String]);

    NSError* error = nil;
    
    /* convert get these out of NSString */
    const char  *name = [p.name UTF8String];
    char        uri[HTTP_MAX_URI];
    
    request = ippNewRequest(CUPS_DELETE_PRINTER);
    
    httpAssembleURIf(HTTP_URI_CODING_ALL, uri, sizeof(uri), "ipp", NULL,
                     "localhost", 0, "/printers/%s", name);
    
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_URI,
                 "printer-uri", NULL, uri);
    
    ippDelete(cupsDoRequest(CUPS_HTTP_DEFAULT, request, "/admin/"));
    
    if (cupsLastError() > IPP_OK_CONFLICT)
    {
        error = [self cupsError:cupsLastErrorString()
                 withReturnCode:1];
    }

  
    
    reply(error);
}

-(void)quitHelper{
    // this will cause the run-loop to exit;
    // you should call it via NSXPCConnection during the applicationShouldTerminate routine
    self.helperToolShouldQuit = YES;
}

//----------------------------------------
// Helper Singleton
//----------------------------------------
+ (helper *)sharedAgent {
    static dispatch_once_t onceToken;
    static helper *shared;
    dispatch_once(&onceToken, ^{
        shared = [helper new];
    });
    return shared;
}


//----------------------------------------
// Set up the one method of NSXPClistener
//----------------------------------------
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperAgent)];
    newConnection.exportedObject = self;
    
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HelperProgress)];
    self.xpcConnection = newConnection;
    
    [newConnection resume];
    return YES;
}

-(NSError*)cupsError:(const char*) msg withReturnCode:(int)rc{
    NSString* m = [NSString stringWithFormat:@"%s.  Error Code: %d",msg,rc];
    NSError* error =[NSError errorWithDomain:@"edu.loyno.smc.Printer-Installer"
                           code:rc
                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                 m,
                                 NSLocalizedDescriptionKey,
                                 nil]];
    return error;
}


@end
