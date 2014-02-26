//
//  PIMenuView.m
//  Printer-Installer
//
//  Created by Eldon on 12/10/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "PIMenuView.h"

@interface PIMenuView ()
{
    BOOL _active;
    NSImageView *_imageView;
    NSStatusItem *_statusItem;
    NSMenu *_statusItemMenu;
}

- (void)refreshView;
- (void)setActive:(BOOL)active;

@end


@implementation PIMenuView

-(id)initWithStatusItem:(NSStatusItem*)statusItem andMenu:(NSMenu *)menu
{
    float ImageViewWidth = 22;
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    self = [super initWithFrame:NSMakeRect(0, 0, ImageViewWidth, height)];
    
    if (self) {
        _statusItem = statusItem;
        _statusItemMenu = menu;
        
        _active = NO;
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, ImageViewWidth, height)];
        _imageView.image = [NSImage imageNamed:@"StatusBar"];
        [self addSubview:_imageView];
        [self refreshView];
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self setActive:YES];
    [_statusItem popUpStatusItemMenu:_statusItemMenu];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self setActive:NO];
}

- (void)drawRect:(NSRect)dirtyRect
{
	if (_active) {
        [[NSColor selectedMenuItemColor] setFill];
        NSRectFill(dirtyRect);
    } else {
        [[NSColor clearColor] setFill];
        NSRectFill(dirtyRect);
    }
}

-(void)refreshView{
    [self setNeedsDisplay:YES];
}

- (void)setActive:(BOOL)active
{
    _active = active;
    [self refreshView];
}

@end
