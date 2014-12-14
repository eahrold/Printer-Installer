//
//  PIBonjourBrowser.h
//  Printer-Installer
//
//  Created by Eldon on 1/15/14.
//  Copyright (c) 2014 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  PIBonjourBrowser,OCPrinter;

@protocol PIBonjourBrowserDelegate <NSObject>
-(void)addBonjourPrinter:(OCPrinter*)printer;
-(void)updateBonjourPrinter:(OCPrinter*)printer;
-(void)removeBonjourPrinter:(NSString*)printerName;
@end

@interface PIBonjourBrowser : NSObject<NSNetServiceBrowserDelegate,NSNetServiceDelegate>

@property BOOL searching;
@property (strong,atomic) NSMutableArray *services;
@property (weak) id<PIBonjourBrowserDelegate>delegate;

- (id)init;
- (id)initWithDelegate:(id<PIBonjourBrowserDelegate>)delegate;

@end

@interface NSNetService (readableTXTRecord){
}
-(NSDictionary*)readableTXTRecord;
@end
