//
//  Helper-SMJobBless.m
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/19/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "Helper-SMJobBless.h"

@implementation JobBlesser

//----------------------------------------------
//  SMJobBless
//----------------------------------------------

+(BOOL)blessHelperWithLabel:(NSString *)helperID
                   andPrompt:(NSString*)prompt
                       error:(NSError**)_error{
    
	BOOL result = NO;
    NSError* error = nil;
    
    if(![self helperNeedsInstalling]){
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
        error = [JobBlesser jobBlessError:@"The Helper tool failed to install due to an Authorization issue, I must now quit" withReturnCode:1];
        
	}else {
        CFErrorRef  cfError;
        result = (BOOL) SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)helperID, authRef, &cfError);
        if (!result) {
            NSLog(@"Problem with SMJobBless: %@",CFBridgingRelease(cfError));
            error = [JobBlesser jobBlessError:@"The Helper tool failed to install due to Certificate Signing issues, I must now quit. Please let the System Admin Know, I assure (s)he will appericaite it." withReturnCode:1];
        }
    }
    
    if ( ! result && (_error != NULL) ) {
        assert(error != nil);
        *_error = error;
    }
    
    return result;
}

+(BOOL)helperNeedsInstalling{
    //This dose the job of checking wether the Helper App needs updateing,
    //Much of this was taken from Eric Gorr's adaptation of SMJobBless http://ericgorr.net/cocoadev/SMJobBless.zip
    OSStatus needsInstalled = YES;
    NSDictionary* installedHelperJobData = nil;
    
    installedHelperJobData = (NSDictionary*)CFBridgingRelease(SMJobCopyDictionary( kSMDomainSystemLaunchd, (CFStringRef)kHelperName ));
    
    if ( installedHelperJobData ){
        NSString* installedPath = [[installedHelperJobData objectForKey:@"ProgramArguments"] objectAtIndex:0];
        NSURL* installedPathURL = [NSURL fileURLWithPath:installedPath];
        NSDictionary* installedInfoPlist = (NSDictionary*)CFBridgingRelease(CFBundleCopyInfoDictionaryForURL((__bridge CFURLRef)(installedPathURL)));
        
        NSString* installedVersion = [installedInfoPlist objectForKey:@"CFBundleVersion"];
        
        // get the version of the helper that is inside of the Main App's bundle
        NSString * wrapperPath = [NSString stringWithFormat:@"Contents/Library/LaunchServices/%@",kHelperName];
        
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
   
    NSMutableArray *aVer = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithArray:[installedVersion componentsSeparatedByString:@"."]]];
    
    NSMutableArray *iVer = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithArray:[avaliableVersion componentsSeparatedByString:@"."]]];

    NSInteger max = 3;
    
    while(aVer.count < max){
        [aVer addObject:@"0"];
    }
    
    while(iVer.count < max){
        NSLog(@"the ivar count:%lu",(unsigned long)iVer.count);
        [iVer addObject:@"0"];
    }
    
    for (NSInteger i=0; i<max; i++) {
        if ([[aVer objectAtIndex:i] integerValue]<[[iVer objectAtIndex:i] integerValue]) {
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

@end