//
//  PICups.m
//  Printer-Installer
//
//  Created by Eldon on 10/18/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PICups.h"

@implementation PICups

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
