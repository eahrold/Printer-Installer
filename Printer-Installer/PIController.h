//
//  PIController.h
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIMenu.h"
#import "PIConfigSheet.h"
#import "Reachability.h"

@interface PIController : NSObject <PIMenuDelegate,PIConfigSheetDelegate>{
    NSStatusItem* statusItem;
}

@property (strong) IBOutlet PIMenu* piMenu;
@property (strong) PIConfigSheet* configSheet;
@property (nonatomic) Reachability *internet;

@end
