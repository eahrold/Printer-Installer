//
//  NSDictionary+NSDictionary_dictFromData.m
//  Printer-Installer
//
//  Created by Eldon on 11/4/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "NSDictionary+NSData.h"

@implementation NSDictionary (NSData)
-(id)initWithData:(NSData*)data{
    self = [super init];
    if (self != nil){
        NSMutableData *md = [NSMutableData dataWithCapacity:1024];
        [md appendData:data];
        
        NSPropertyListFormat plist;
        self = (NSDictionary*)[NSPropertyListSerialization
                                            propertyListWithData:md
                                            options:NSPropertyListMutableContainersAndLeaves
                                            format:&plist
                                            error:nil];
    }
    return self;
}

+(NSDictionary*)dictionaryFromData:(NSData*)data{
    NSMutableData *md = [NSMutableData dataWithCapacity:1024];
    [md appendData:data];

    NSPropertyListFormat plist;
    NSDictionary* dict = (NSDictionary*)[NSPropertyListSerialization
                           propertyListWithData:md
                           options:NSPropertyListMutableContainersAndLeaves
                           format:&plist
                           error:nil];
    return dict;
}
@end
