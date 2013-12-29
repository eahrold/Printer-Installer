//
//  Printer.m
//  Secure Classes
//
//  Created by Eldon Ahrold on 8/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Printer.h"
#import "PIError.h"
#import <syslog.h>
#import <cups/cups.h>
#import <cups/ppd.h>

@implementation Printer{
    ipp_t           *request;
    http_t          *http;
}

#pragma mark - Initializers / Secure Coding
- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super init];
    if (self) {
        NSSet* whiteList = [NSSet setWithObjects:[NSArray class],[NSString class],[NSDictionary class], nil];
        _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _host = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"host"];
        _location = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"location"];
        _description = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"description"];
        _ppd = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"ppd"];
        _model = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"model"];
        _protocol = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"protocol"];
        _url = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"url"];
        _host = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"host"];
        _options = [aDecoder decodeObjectOfClasses:whiteList forKey:@"options"];
    }
    return self;
}

+ (BOOL)supportsSecureCoding { return YES; }

- (void)encodeWithCoder:(NSCoder*)aEncoder {
    [aEncoder encodeObject:_name forKey:@"name"];
    [aEncoder encodeObject:_host forKey:@"host"];
    [aEncoder encodeObject:_location forKey:@"location"];
    [aEncoder encodeObject:_description forKey:@"description"];
    [aEncoder encodeObject:_ppd forKey:@"ppd"];
    [aEncoder encodeObject:_model forKey:@"model"];
    [aEncoder encodeObject:_protocol forKey:@"protocol"];
    [aEncoder encodeObject:_url forKey:@"url"];
    [aEncoder encodeObject:_host forKey:@"host"];
    [aEncoder encodeObject:_options forKey:@"options"];
}

-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    if(self){
        [self setValuesForKeysWithDictionary:dict];
        if(!_url)
            if(![self configureURL:nil]){
                return nil;
            };
    }
    return self;
}

-(BOOL)configureURI{
    return [self configureURL:nil];
}

#pragma mark - CUPS Wrappers
-(BOOL)addPrinter{
    return [self addPrinter:nil];
}
-(BOOL)addPrinter:(NSError *__autoreleasing*)error{
    if(![self nameIsValid:error])return NO;
    if(![self configurePPD:error])return NO;
    
    ppd_file_t      *ppd;
    cups_file_t     *inppd;
    cups_file_t     *outppd;
    ppd_choice_t	*choice;
    cups_option_t	*options = NULL;
    
    int
    num_options         = 0,
    ppdchanged          = 0,
    wrote_ipp_supplies  = 0;
    
    const char  *customval;
    
    char    uri[HTTP_MAX_URI],
            line[1024],         /* Line from PPD file */
            keyword[1024],		/* Keyword from Default line */
            *keyptr,            /* Pointer into keyword... */
            tempfile[1024];		/* Temporary filename */
    
    request = ippNewRequest(CUPS_ADD_MODIFY_PRINTER);
    http = httpConnectEncrypt(cupsServer(), ippPort(),cupsEncryption());
    
    if(_location.UTF8String){
        num_options = cupsAddOption("printer-location", _location.UTF8String, num_options, &options);
    }
    
    if(_description.UTF8String){
        num_options = cupsAddOption("printer-info", _description.UTF8String, num_options, &options);
    }
    
    if(_options){
        for(NSString* opt in _options){
            num_options = cupsParseOptions([opt UTF8String], num_options, &options);
        }
    }
    
    num_options = cupsAddOption("device-uri", _url.UTF8String,
                              num_options, &options);
    
    httpAssembleURIf(HTTP_URI_CODING_ALL, uri, sizeof(uri), "ipp", NULL,
                     "localhost", 0, "/printers/%s", _name.UTF8String);
    
    
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_URI,"printer-uri", NULL, uri);
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_NAME,"requesting-user-name", NULL, cupsUser());
    ippAddInteger(request, IPP_TAG_PRINTER, IPP_TAG_ENUM, "printer-state", IPP_PRINTER_IDLE);
    ippAddBoolean(request, IPP_TAG_PRINTER, "printer-is-accepting-jobs", 1);
    
    cupsEncodeOptions2(request, num_options, options, IPP_TAG_PRINTER);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// silence the depericiaton warnings untill Apple starts to use
// the standard lpoptions files rather than needing them hard coded
// into the PPD file.
    ppd = ppdOpenFile(_ppd.UTF8String);
    ppdMarkDefaults(ppd);
    cupsMarkOptions(ppd, num_options, options);
    
    if ((outppd = cupsTempFile2(tempfile, sizeof(tempfile))) == NULL){
        ippDelete(request);
        if(error)*error = [PIError errorWithCode:PICantWriteFile];
        return NO;
    }
    
    if ((inppd = cupsFileOpen(_ppd.UTF8String, "r")) == NULL)
    {
        ippDelete(request);
        cupsFileClose(outppd);
        unlink(tempfile);
        if(error)*error =  [PIError errorWithCode:PICantOpenPPD];
        return NO;
    }
    
    ppdchanged = 0;
    wrote_ipp_supplies = 1;
    
    while (cupsFileGets(inppd, line, sizeof(line)))
    {
        if (strncmp(line, "*Default", 8))
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
                else if ((customval = cupsGetOption(keyword, num_options,
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
    cupsFileClose(inppd);
    cupsFileClose(outppd);
    ppdClose(ppd);
#pragma clang diagnostic pop
  
    ippAddInteger(request, IPP_TAG_PRINTER, IPP_TAG_ENUM, "printer-state", IPP_PRINTER_IDLE);
    ippAddBoolean(request, IPP_TAG_PRINTER, "printer-is-accepting-jobs", 1);
    ippDelete(cupsDoFileRequest(CUPS_HTTP_DEFAULT, request, "/admin/", ppdchanged ? tempfile : _ppd.UTF8String));
    
    
    if (cupsLastError() > IPP_OK_CONFLICT)
    {
        if(error)*error = [PIError cupsError:1 message:cupsLastErrorString()];
        return NO;
    }

    
    return YES;
}
-(BOOL)addOptions:(NSArray *)opts{
    cups_option_t	*options = NULL;
    int             num_options = 0;

    cups_dest_t     *dest = NULL;
    cups_dest_t     *dests = NULL;
    int             num_dests = 0;

    char            *printer,
                    *instance,
                    option;
    
    printer = (char*)self.name.UTF8String;
    
    if ((instance = strrchr(printer, '/')) != NULL)
        *instance++ = '\0';
    
    if (num_dests == 0)
        num_dests = cupsGetDests(&dests);
    
    if ((dest = cupsGetDest(printer, instance, num_dests, dests)) == NULL)
    {
        num_dests = cupsAddDest(printer, instance, num_dests, &dests);
        dest      = cupsGetDest(printer, instance, num_dests, dests);
        
        if (dest == NULL)
        {
	        NSLog(@"unable to locate printer %@", self.name);
            return (1);
        }
    }
    
    
    if(opts.count){
        for(NSString* opt in opts){
            num_options = cupsParseOptions(opt.UTF8String, num_options, &options);
        }
    }
    
    cupsEncodeOptions2(request, num_options, options, IPP_TAG_PRINTER);
    
    return YES;
}

-(BOOL)addOption:(NSString *)opt{
   return [self addOptions:@[opt]];
}

-(BOOL)removePrinter{
    return [self removePrinter:nil];
}
-(BOOL)removePrinter:(NSError *__autoreleasing*)error{
    /* convert get these out of NSString */
    char            uri[HTTP_MAX_URI];
    
    request = ippNewRequest(CUPS_DELETE_PRINTER);
    
    httpAssembleURIf(HTTP_URI_CODING_ALL, uri, sizeof(uri), "ipp", NULL,
                     "localhost", 0, "/printers/%s", _name.UTF8String);
    
    ippAddString(request, IPP_TAG_OPERATION, IPP_TAG_URI,
                 "printer-uri", NULL, uri);
    
    ippDelete(cupsDoRequest(CUPS_HTTP_DEFAULT, request, "/admin/"));
    
    if (cupsLastError() > IPP_OK_CONFLICT)
    {
        if(error)*error = [PIError cupsError:1 message:cupsLastErrorString()];
        return NO;
    }
    
    return YES;
}


#pragma mark - private methods
-(BOOL)configurePPD:(NSError*__autoreleasing*)error{
    NSString* path;
    // check if we have the PPD locally

#if DEBUG
    syslog(1, "the model %s ",_model.UTF8String);
    syslog(1, "the host %s ",_host.UTF8String);
    syslog(1, "the name %s ",_name.UTF8String);
    syslog(1, "the protocol %s ",_protocol.UTF8String);
#endif
    
    path = [NSString stringWithFormat:@"/Library/Printers/PPDs/Contents/Resources/%@.gz",_model];

    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        _ppd = path;
        return YES;
    }
    
    // if not local, try and get if from the printer-installer-server
    path = [_ppd_url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if([self downloadPPD:[NSURL URLWithString:path]]){
        return YES;
    }
    
    // otherwise, if it's getting shared via ipp, try to grab it from the CUPS server
    if([_protocol isEqualToString:@"ipp"]){
        path = [NSString stringWithFormat:@"http://%@:631/printers/%@.ppd",_host,_name];
        if([self downloadPPD:[NSURL URLWithString:path]]){
            return YES;
        }
    }
    
    // if we still don't have it error out
    if(error)*error = [PIError errorWithCode:PIPPDNotFound];
    return NO;
}

-(BOOL)configureURL:(NSError*__autoreleasing*)error{
    if(!_name || !_protocol || !_host){
        NSString *errMsg = [NSString stringWithFormat:@"Values Cannot be empty printer:%@ protocol:%@ host:%@",_name,_protocol,_host];
        if(error)*error = [PIError errorWithCode:PIIncompletePrinter message:errMsg];
        return NO;
    }
    
    // ipp and ipps for connecting to CUPS server
    if([_protocol isEqualToString:@"ipp"]||[_protocol isEqualToString:@"ipps"]){
        _url = [NSString stringWithFormat:@"%@://%@/printers/%@",_protocol,_host,_name];
    }
    // http and https for connecting to CUPS server
    else if([_protocol isEqualToString:@"http"] || [_protocol isEqualToString:@"https"]){
        _url = [NSString stringWithFormat:@"%@://%@:631/printers/%@",_protocol,_host,_name];
    }
    // socket for connecting to AppSocket
    else if([_protocol isEqualToString:@"socket"]){
        _url = [NSString stringWithFormat:@"%@://%@:9100",_protocol,_host];
    }
    else if([_protocol isEqualToString:@"lpd"]){
        _url = [NSString stringWithFormat:@"%@://%@",_protocol,_host];
    }
    else if([_protocol isEqualToString:@"smb"]){
        _url = [NSString stringWithFormat:@"%@://%@/%@",_protocol,_host,_name];
    }
    else{
        if(error)*error = [PIError errorWithCode:PIInvalidProtocol];
        return NO;
    }
    return YES;
}

-(BOOL)downloadPPD:(NSURL*)URL{
    if(!URL){
        syslog(1, "the url %s isn't valid",[URL path].UTF8String);
        return NO;
    }
    
    NSError* error = nil;
    NSURLResponse* response = nil;
    
    // Create the request.
    NSMutableURLRequest *ppdRequest = [NSMutableURLRequest requestWithURL:URL];
    
    // set as GET request
    ppdRequest.HTTPMethod = @"GET";
    ppdRequest.timeoutInterval = 3;
    
    // set header fields
    [ppdRequest setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    NSData* data = [NSURLConnection sendSynchronousRequest:ppdRequest returningResponse:&response error:&error];
    NSString* downloadedPPD = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gz",_name]];
    
    NSInteger rc = [((NSHTTPURLResponse *)response) statusCode];
    
    if(rc >= 400){
        error = [PIError errorWithCode:PIServerNotFound];
    }
    
    if(error){
        syslog(1,"error: %s",[error.localizedDescription UTF8String]);
        _ppd = nil;
    }else{
        if([[NSFileManager defaultManager] createFileAtPath:downloadedPPD contents:data attributes:nil]){
            _ppd = downloadedPPD;
            return YES;
        }else{
            syslog(1,"there was a problem Creating the PPD File");
        }
    }
    return NO;
}

-(BOOL)nameIsValid:(NSError*__autoreleasing*)error{
    const char  *name = _name.UTF8String;
    const char	*ptr;
    
    for (ptr = name; *ptr; ptr ++){
        if (*ptr == '@'){
            break;
        }else if
            ((*ptr >= 0 && *ptr <= ' ') || *ptr == 127 || *ptr == '/' ||
             *ptr == '#'){
                if(error)*error = [PIError errorWithCode:1008 message:@"Printer name can only contain printable characters"];
                return NO;
        }
    }
    
    /*
     * All the characters are good; validate the length, too...
     */
    if((ptr - name) > 127){
        if(error)*error = [PIError errorWithCode:1009 message:@"Printer Name is Too Long"];
        return NO;
    }
    return YES;
}

#pragma mark - Class Methods
+(NSSet*)getInstalledPrinters{
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
