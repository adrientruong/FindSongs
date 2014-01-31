//
//  NSString+UUID.m
//  FindSongs
//
//  Created by Adrien Truong on 12/27/12.
//  Copyright (c) 2012 Adrien Truong. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString *)UUID
{
    
    CFUUIDRef UUIID = CFUUIDCreate(NULL);
    
    NSString *uniqueIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, UUIID);
    
    CFRelease(UUIID);
    
    return uniqueIDString;
    
}

@end
