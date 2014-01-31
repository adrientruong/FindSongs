//
//  BDDiscreteProgressCell.m
//  ProgressInNSTableView
//
//  Created by Brian Dunagan on 12/6/08.
//  Copyright 2008 bdunagan.com. All rights reserved.
//

#import "BDDiscreteProgressCell.h"

@implementation BDDiscreteProgressCell

@synthesize progress;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if (self != nil) {
        
        self.progress = [[NSProgressIndicator alloc] init];
        
    }
    
    return self;
    
}

- (void)drawInteriorWithFrame:(NSRect)aRect inView:(NSView *)controlView
{
    
	[super drawInteriorWithFrame:aRect inView:controlView];
	
	NSRect progressRect = NSMakeRect(aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
    
	progressRect.origin.x += 20;
	progressRect.origin.y += 4;
	progressRect.size.width -= 24;
    
	[progress setFrame:progressRect];
    
	[progress sizeToFit];
    
}

- (void)setProgress:(NSProgressIndicator *)newProgress
{
    
	progress = newProgress;
	
	[progress sizeToFit];
    
}

@end
