//
//  PIController.h
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIMenu.h"
#import "PIPannelController.h"

@interface PIController : NSObject <PIMenuDelegate,PICConfigMenuDelegate>{
    NSStatusItem* statusItem;
}

@property (weak) IBOutlet PIMenu* piMenu;
@property (strong,nonatomic) PIPannelCotroller* configSheet;


@end
