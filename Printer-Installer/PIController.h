//
//  PIController.h
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PIMenu.h"
#import "PIConfigView.h"
#import "PIBonjourBrowser.h"
#import "Reachability.h"

@interface PIController : NSObject <PIMenuDelegate,PIConfigViewControllerDelegate>{
}

@property (strong) IBOutlet PIMenu* menu;
@property (nonatomic) Reachability *internet;

@end
