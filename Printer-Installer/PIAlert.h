//
//  PIAlert.h
//  Printer-Installer
//
//  Created by Eldon on 12/29/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PIAlertCode){
    kPIAlertSuccess = 0,
    kPIAlertHelperToolRemoved = 2000,
};

@interface PIAlert : NSObject
+(void)showAlertWithCode:(PIAlertCode)code didEndSelector:(SEL)selector;

@end
