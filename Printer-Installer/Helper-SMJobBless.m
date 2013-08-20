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
                       error:(NSError**)error {
    
    OSStatus result;
    
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
    AuthorizationEnvironment environment = {0, NULL};
    
    if (prompt)
    {
        AuthorizationItem envItem = {
            kAuthorizationEnvironmentPrompt, prompt.length, (void*)prompt.UTF8String, 0
        };
        
        environment.count = 1;
        environment.items = &envItem;
    }
    
	AuthorizationFlags authFlags		=	kAuthorizationFlagDefaults				|
    kAuthorizationFlagInteractionAllowed	|
    kAuthorizationFlagPreAuthorize			|
    kAuthorizationFlagExtendRights;
    
	AuthorizationRef authRef = NULL;
	
    result = AuthorizationCreate(&authRights, &environment, authFlags, &authRef);
    
	if (result != errAuthorizationSuccess) {
        NSLog(@"Failed to create AuthorizationRef. Error code: %d", result);
        result = NO;
        
	} else {
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)CFBridgingRetain(helperID), authRef, (CFErrorRef *)nil);
	}
    
	AuthorizationFree (authRef, kAuthorizationFlagDefaults);
	return result;
}


+(BOOL)helperNeedsInstalling{
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

@end
