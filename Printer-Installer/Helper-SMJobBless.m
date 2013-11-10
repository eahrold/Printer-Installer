//
//  Helper-SMJobBless.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/19/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Helper-SMJobBless.h"

@implementation JobBlesser

NSString* const JBAuthError = @"The Helper tool failed to install due to an Authorization issue, I must now quit";

NSString* const JBCertError = @"The Helper tool failed to install due to Certificate Signing issues, I must now quit. Please let the System Admin Know, I assure (s)he will appericaite it.";
//----------------------------------------------
//  SMJobBless
//----------------------------------------------

+(BOOL)blessHelperWithLabel:(NSString *)helperID
                   andPrompt:(NSString*)prompt
                       error:(NSError**)error{
    NSError* localError = nil;
	BOOL result = NO;
    
    if(![self helperNeedsInstalling:helperID]){
        return YES;
    }
    
    AuthorizationRef authRef = NULL;
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
    AuthorizationEnvironment environment = {0, NULL};
    
    AuthorizationFlags authFlags    =   kAuthorizationFlagDefaults				|
                                        kAuthorizationFlagInteractionAllowed    |
                                        kAuthorizationFlagPreAuthorize          |
                                        kAuthorizationFlagExtendRights;
    
    if(prompt){
        AuthorizationItem envItem = {
            kAuthorizationEnvironmentPrompt, prompt.length, (void*)prompt.UTF8String, 0
        };
        environment.count = 1;
        environment.items = &envItem;
    }
    
	   
    OSStatus status = AuthorizationCreate(&authRights, &environment, authFlags, &authRef);
    
	if (status != errAuthorizationSuccess) {
        NSLog(@"Failed to create AuthorizationRef. Error code: %d", status);
        localError = [JobBlesser jobBlessError:JBAuthError withReturnCode:1];
        
	}else {
        CFErrorRef  cfError;
        result = (BOOL)SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)helperID, authRef, &cfError);
        if (!result) {
            NSLog(@"Problem with SMJobBless: %@",CFBridgingRelease(cfError));
            localError = [JobBlesser jobBlessError:JBCertError withReturnCode:1];
        }
    }
    
    if ( !result && (localError != NULL) ) {
        assert(localError != nil);
    }
    
    if(error)*error = localError;
    return result;
}

+(BOOL)removeHelperWithLabel:(NSString*)helperID{
    BOOL result = YES;
    NSError* localError = nil;

    NSString* prompt = @"Remove Helper tool?";
    
    AuthorizationRef authRef = NULL;
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
    AuthorizationEnvironment environment = {0, NULL};
    
    AuthorizationFlags authFlags    =   kAuthorizationFlagDefaults				|
    kAuthorizationFlagInteractionAllowed    |
    kAuthorizationFlagPreAuthorize          |
    kAuthorizationFlagExtendRights;
    
    if(prompt){
        AuthorizationItem envItem = {
            kAuthorizationEnvironmentPrompt, prompt.length, (void*)prompt.UTF8String, 0
        };
        environment.count = 1;
        environment.items = &envItem;
    }
    
    
    OSStatus status = AuthorizationCreate(&authRights, &environment, authFlags, &authRef);
    
	if (status != errAuthorizationSuccess) {
        NSLog(@"Failed to create AuthorizationRef. Error code: %d", status);
        localError = [JobBlesser jobBlessError:@"Coulnd't remove" withReturnCode:1];
        
	}else {
        NSLog(@"Trying to remove helper tool");
        CFErrorRef  cfError;
        result = SMJobRemove(kSMDomainSystemLaunchd, (__bridge CFStringRef)helperID, authRef,NO, &cfError);
        
        if (!result) {
            NSLog(@"Problem with SMJobBless: %@",CFBridgingRelease(cfError));
            localError = [JobBlesser jobBlessError:JBCertError withReturnCode:1];
        }
    }
    
    if ( !result && (localError != NULL) ) {
        assert(localError != nil);
        NSLog(@"we errored somewhere %@",localError.localizedDescription);

    }
    
    return result;

}

+(BOOL)helperNeedsInstalling:(NSString*)helperID{
    
    //This dose the job of checking wether the Helper App needs updateing,
    //Much of this was taken from Eric Gorr's adaptation of SMJobBless http://ericgorr.net/cocoadev/SMJobBless.zip
    OSStatus needsInstalled = YES;
    NSDictionary* installedHelperJobData = nil;
    
    installedHelperJobData = (NSDictionary*)CFBridgingRelease(SMJobCopyDictionary( kSMDomainSystemLaunchd, (__bridge CFStringRef)helperID ));
    
    if ( installedHelperJobData ){
        NSString* installedPath = [[installedHelperJobData objectForKey:@"ProgramArguments"] objectAtIndex:0];
        NSURL* installedPathURL = [NSURL fileURLWithPath:installedPath];
        NSDictionary* installedInfoPlist = (NSDictionary*)CFBridgingRelease(CFBundleCopyInfoDictionaryForURL((__bridge CFURLRef)(installedPathURL)));
        
        NSString* installedVersion = [installedInfoPlist objectForKey:@"CFBundleVersion"];
        
        // get the version of the helper that is inside of the Main App's bundle
        NSString * wrapperPath = [NSString stringWithFormat:@"Contents/Library/LaunchServices/%@",helperID];
        
        NSBundle* appBundle = [NSBundle mainBundle];
        NSURL* appBundleURL	= [appBundle bundleURL];
        NSURL* currentHelperToolURL	= [appBundleURL URLByAppendingPathComponent:wrapperPath];
        NSDictionary* currentInfoPlist = (NSDictionary*)CFBridgingRelease(CFBundleCopyInfoDictionaryForURL((__bridge CFURLRef)(currentHelperToolURL)));
        NSString* avaliableVersion = [currentInfoPlist objectForKey:@"CFBundleVersion"];
        

        //NSLog( @"Currently installed helper version: %@", installedVersion );
        //NSLog( @"Avaliable helper version: %@", avaliableVersion );
        
        if(!installedVersion){
            needsInstalled = YES;
        }else{
            if([self checkIfVersion:avaliableVersion isGreaterThan:installedVersion]){
                needsInstalled = YES;
            }else{
                needsInstalled = NO;
            }
        }
	}
    return needsInstalled;
}

+(BOOL)checkIfVersion:(NSString*)avaliableVersion isGreaterThan:(NSString*)installedVersion{
   
    NSMutableArray *iVer = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithArray:[installedVersion componentsSeparatedByString:@"."]]];
    
    NSMutableArray *aVer = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithArray:[avaliableVersion componentsSeparatedByString:@"."]]];

    NSInteger max = 3;
    
    while(aVer.count < max){
        [aVer addObject:@"0"];
    }
    
    while(iVer.count < max){
        [iVer addObject:@"0"];
    }
    
    for (NSInteger i=0; i<max; i++) {
        if ([[aVer objectAtIndex:i] integerValue]>[[iVer objectAtIndex:i] integerValue]) {
            return YES;
        }        
    }
    return NO;
}

+(NSError*)jobBlessError:(NSString*)msg withReturnCode:(int)rc{
    NSError* error =[NSError errorWithDomain:@"edu.loyno.smc.Printer-Installer"
                                        code:rc
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                              msg,
                                              NSLocalizedDescriptionKey,
                                              nil]];
    return error;
}


+(void)addLoginItem:(NSString*)helperID
{
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)helperID, true)) {
        NSLog(@"SMLoginItemSetEnabled(..., true) failed");
    }
}

+(void)removeLoginItem:(NSString*)helperID
{
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)helperID, false)) {
        NSLog(@"SMLoginItemSetEnabled(..., false) failed");
    }
}

+(void)setLaunchOnLogin:(BOOL)value withLabel:(NSString*)helperID
{
    if (!value) {
        NSLog(@"Removing Login Item");
        [self removeLoginItem:helperID];
    } else {
        NSLog(@"Adding Login Item");
        [self addLoginItem:helperID];
    }
}

+(BOOL)launchOnLogin:(NSString*)helperID
{
    NSArray *jobs = (__bridge NSArray*)SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    if (jobs == nil) {
        return NO;
    }
    
    if ([jobs count] == 0) {
        CFRelease((__bridge CFArrayRef)jobs);
        return NO;
    }
    
    BOOL onDemand = NO;
    for (NSDictionary *job in jobs) {
        if ([helperID isEqualToString:[job objectForKey:@"Label"]]) {
            onDemand = [[job objectForKey:@"OnDemand"] boolValue];
            break;
        }
    }
    
    CFRelease((__bridge CFArrayRef)jobs);
    return onDemand;
}


@end