//
//  NSDictionary+NSDictionary_dictFromData.h
//  Server Framework
//
//  Created by Eldon on 11/4/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSData)
-(id)initWithData:(NSData*)data;
+(NSDictionary*)dictionaryFromData:(NSData*)data;
@end
