//
//  PIAppController.h
//  Printer-Installer
//
//  Created by Eldon on 11/9/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PIStatusBar;

@interface PIAppController : NSObject
@property (weak) IBOutlet PIStatusBar* statusBar;

-(IBAction)refreshPrinterList:(id)sender;

@end
