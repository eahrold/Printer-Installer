//
//  main.m
//  printer-installer-helper
//
//  Created by Eldon Ahrold on 8/16/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "helper.h"



int main(int argc, const char *argv[])
{
    @autoreleasepool {
        PIHelper *helper = [PIHelper new];
        [helper run];
    }
	return 0;
}

