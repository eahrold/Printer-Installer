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

@interface PIController : NSObject <PIMenuDelegate,PIConfigSheetDelegate>{
    NSStatusItem* statusItem;
}

@property (weak) IBOutlet PIMenu* piMenu;
@property (strong,nonatomic) PIConfigSheet* configSheet;


@end
