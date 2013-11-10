//
//  helper.m
//  Printer Installer
//
//  Created by Eldon Ahrold on 8/15/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//
// much of this is taken from lpadmin.c from CUPS.org source code
// http://www.cups.org/software.php?VERSION=1.6.2
// and I would like to acknowledge the excelent work
// of Matt Sweet and his team at cups.org

#import "helper.h"
#import <cups/cups.h>
#import <cups/ppd.h>

#import <syslog.h>

@implementation helper


-(void)addPrinter:(NSDictionary *)printer withReply:(void (^)(NSError *))reply{
    Printer* p = [[Printer alloc]initWithDict:printer];
    [p configurePPD];
    
    NSError* error = nil;

    ipp_t           *request;
    ppd_file_t      *ppd;
    cups_file_t     *inppd;
    cups_file_t     *outppd;
    ppd_choice_t	*choice;
    cups_option_t	*options = NULL;

    int     opt_count           = 0,
            ppdchanged          = 0,
            wrote_ipp_supplies  = 0,
            wrote_snmp_supplies = 0;

    const char  *customval,
                *boolval;

    char        uri[HTTP_MAX_URI],
                line[1024],         /* Line from PPD file */
                keyword[1024],		/* Keyword from Default line */
                *keyptr,            /* Pointer into keyword... */
                tempfile[1024];		/* Temporary filename */
    
    
    if(p.error){
        syslog(1,"printer-installer error %s",[p.error.localizedDescription UTF8String]);
        error = p.error;
        goto nsxpc_reply;
    }
    
    request = ippNewRequest(CUPS_ADD_MODIFY_PRINTER);
    
    if(p.location.UTF8String){
        opt_count = cupsAddOption("printer-location", p.location.UTF8String, opt_count, &options);
    }
    
    if(p.description.UTF8String){
        opt_count = cupsAddOption("printer-info", p.description.UTF8String, opt_count, &options);
    }
    
    if(p.options){
        for(NSString* opt in p.options){
            opt_count = cupsParseOptions([opt UTF8String], opt_count, &options);
        }
    }
    
    opt_count = cupsAddOption("device-uri", p.url.UTF8String,
                              opt_count, &options);
    
    httpAssembleURIf(HTTP_URI_CODING_ALL, uri, sizeof(uri), "ipp", NULL,
                     "localhost", 0, "/printers/%s", p.name.UTF8String);
    
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_URI,
                 "printer-uri", NULL, uri);
    
    cupsEncodeOptions2(request, opt_count, options, IPP_TAG_PRINTER);
    
    ppd = ppdOpenFile(p.ppd.UTF8String);
    ppdMarkDefaults(ppd);
    cupsMarkOptions(ppd, opt_count, options);
    
    if ((outppd = cupsTempFile2(tempfile, sizeof(tempfile))) == NULL){
        ippDelete(request);
        error = [PIError errorWithCode:PICantWriteFile];
        goto nsxpc_reply;
    }
    
    if ((inppd = cupsFileOpen(p.ppd.UTF8String, "r")) == NULL)
    {
        ippDelete(request);
        error = [PIError errorWithCode:PICantOpenPPD];
        
        cupsFileClose(outppd);
        unlink(tempfile);
        goto nsxpc_reply;
    }

    ppdchanged = 0;
    wrote_ipp_supplies = 1;
    
    while (cupsFileGets(inppd, line, sizeof(line)))
    {
        if (!strncmp(line, "*cupsIPPSupplies:", 17) &&
            (boolval = cupsGetOption("cupsIPPSupplies", opt_count, options)) != NULL)
        {
            wrote_ipp_supplies = 1;
            cupsFilePrintf(outppd, "*cupsIPPSupplies: %s\n",
                           ( !_cups_strcasecmp(boolval, "true") ||
                             !_cups_strcasecmp(boolval, "yes") ||
                             !_cups_strcasecmp(boolval, "on")) ? "True" : "False");
        }
        else if (!strncmp(line, "*cupsSNMPSupplies:", 18) &&
                 (boolval = cupsGetOption("cupsSNMPSupplies", opt_count,
                                          options)) != NULL)
        {
            wrote_snmp_supplies = 1;
            cupsFilePrintf(outppd, "*cupsSNMPSupplies: %s\n",
                           (!_cups_strcasecmp(boolval, "true") ||
                            !_cups_strcasecmp(boolval, "yes") ||
                            !_cups_strcasecmp(boolval, "on")) ? "True" : "False");
        }
        else if (strncmp(line, "*Default", 8))
            cupsFilePrintf(outppd, "%s\n", line);
        else
        {
            /*
             * Get default option name...
             */
            
            strlcpy(keyword, line + 8, sizeof(keyword));
            
            for (keyptr = keyword; *keyptr; keyptr ++)
                if (*keyptr == ':' || isspace(*keyptr & 255))
                    break;
            
            *keyptr++ = '\0';
            while (isspace(*keyptr & 255))
                keyptr ++;
            
            if (!strcmp(keyword, "PageRegion") ||
                !strcmp(keyword, "PageSize") ||
                !strcmp(keyword, "PaperDimension") ||
                !strcmp(keyword, "ImageableArea"))
            {
                if ((choice = ppdFindMarkedChoice(ppd, "PageSize")) == NULL)
                    choice = ppdFindMarkedChoice(ppd, "PageRegion");
            }
            else
                choice = ppdFindMarkedChoice(ppd, keyword);
            
            if (choice && strcmp(choice->choice, keyptr))
            {
                if (strcmp(choice->choice, "Custom"))
                {
                    cupsFilePrintf(outppd, "*Default%s: %s\n", keyword, choice->choice);
                    ppdchanged = 1;
                }
                else if ((customval = cupsGetOption(keyword, opt_count,
                                                    options)) != NULL)
                {
                    cupsFilePrintf(outppd, "*Default%s: %s\n", keyword, customval);
                    ppdchanged = 1;
                }
                else
                    cupsFilePrintf(outppd, "%s\n", line);
            }
            else
                cupsFilePrintf(outppd, "%s\n", line);
        }
    }
    
    if (!wrote_ipp_supplies &&
        (boolval = cupsGetOption("cupsIPPSupplies", opt_count,
                                 options)) != NULL)
    {
        cupsFilePrintf(outppd, "*cupsIPPSupplies: %s\n",
                       (!_cups_strcasecmp(boolval, "true") ||
                        !_cups_strcasecmp(boolval, "yes") ||
                        !_cups_strcasecmp(boolval, "on")) ? "True" : "False");
    }
    
    
    if (!wrote_snmp_supplies &&
        (boolval = cupsGetOption("cupsSNMPSupplies", opt_count,
                                 options)) != NULL)
    {
        cupsFilePrintf(outppd, "*cupsSNMPSupplies: %s\n",
                       (!_cups_strcasecmp(boolval, "true") ||
                        !_cups_strcasecmp(boolval, "yes") ||
                        !_cups_strcasecmp(boolval, "on")) ? "True" : "False");
    }
    
    cupsFileClose(inppd);
    cupsFileClose(outppd);
    ppdClose(ppd);

    
    ippAddInteger(request, IPP_TAG_PRINTER, IPP_TAG_ENUM, "printer-state", IPP_PRINTER_IDLE);
    ippAddBoolean(request, IPP_TAG_PRINTER, "printer-is-accepting-jobs", 1);
    ippDelete(cupsDoFileRequest(CUPS_HTTP_DEFAULT, request, "/admin/", ppdchanged ? tempfile : p.ppd.UTF8String));
    
    
    if (cupsLastError() > IPP_OK_CONFLICT)
    {
        error = [PIError cupsError:1 message:cupsLastErrorString()];
    }
    
    
nsxpc_reply:
    reply(error);
}

-(void)removePrinter:(NSDictionary *)printer withReply:(void (^)(NSError *))reply{
    NSString* p = [printer objectForKey:@"name"];
    syslog(1,"Removing printer %s",[p UTF8String]);
    NSError *error = nil;
    
    /* convert get these out of NSString */
    char            uri[HTTP_MAX_URI];
    
    ipp_t* request = ippNewRequest(CUPS_DELETE_PRINTER);
    
    httpAssembleURIf(HTTP_URI_CODING_ALL, uri, sizeof(uri), "ipp", NULL,
                     "localhost", 0, "/printers/%s", p.UTF8String);
    
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_URI,
                 "printer-uri", NULL, uri);
    
    ippDelete(cupsDoRequest(CUPS_HTTP_DEFAULT, request, "/admin/"));
    
    if (cupsLastError() > IPP_OK_CONFLICT)
    {
        error = [PIError cupsError:1 message:cupsLastErrorString()];
    }

  
    
    reply(error);
}

-(void)quitHelper{
    // this will cause the run-loop to exit;
    // you should call it via NSXPCConnection during the applicationShouldTerminate routine
    self.helperToolShouldQuit = YES;
}

-(void)installLoginItem:(NSURL*)loginItem{
    syslog(1,"installing loginitem");
    AuthorizationRef auth = NULL;
    LSSharedFileListRef globalLoginItems = LSSharedFileListCreate(NULL, kLSSharedFileListGlobalLoginItems, NULL);
    LSSharedFileListSetAuthorization(globalLoginItems, auth);
    
    if (globalLoginItems) {
        LSSharedFileListItemRef ourLoginItem = LSSharedFileListInsertItemURL(globalLoginItems,
                                                                             kLSSharedFileListItemLast,
                                                                             NULL, NULL,
                                                                             (__bridge CFURLRef)loginItem,
                                                                             NULL, NULL);
        if (ourLoginItem) {
            CFRelease(ourLoginItem);
        } else {
            syslog(1,"Could not insert ourselves as a global login item");
        }
        
        CFRelease(globalLoginItems);
    } else {
        syslog(1,"Could not get the global login items");
    }
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

@end
