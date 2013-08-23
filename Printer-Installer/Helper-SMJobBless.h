//
//  Helper-SMJobBless.h
//  Printer-Installer
//
//  Created by Eldon Ahrold on 8/19/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ServiceManagement/ServiceManagement.h>

#import "Interfaces.h"


@interface JobBlesser : NSObject

+(BOOL)blessHelperWithLabel:(NSString *)label
                  andPrompt:(NSString*)prompt
                      error:(NSError**)error;

@end
