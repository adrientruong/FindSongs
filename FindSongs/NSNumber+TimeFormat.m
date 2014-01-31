//
//  NSNumber+TimeFormat.m
//  FindSongs
//
//  Created by Adrien Truong on 12/26/12.
//  Copyright (c) 2012 Adrien Truong. All rights reserved.
//

#import "NSNumber+TimeFormat.h"
#import "TMKUtilities.h"

@implementation NSNumber (TimeFormat)

- (NSString *)stringWithMMSSFormat
{
    
    return [TMKUtilities mmssStringFromTimeInterval:self.doubleValue];
    
}

@end
