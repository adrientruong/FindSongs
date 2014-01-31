//
//  TMKUtilities.m
//  Tabata
//
//  Created by Adrien Truong on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TMKUtilities.h"

@implementation TMKUtilities

+ (NSDateComponents *)getHour:(BOOL)getHour minute:(BOOL)getMinute second:(BOOL)getSecond fromTimeInterval:(NSTimeInterval)timeInterval {
    
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    int timeIntervalInt = timeInterval;
    
    if (getHour) {
        int hour = timeIntervalInt / 3600;    
        timeIntervalInt -= (hour * 3600);
        
        components.hour = hour;
    }
        
    if (getMinute) {

        int minute =  timeIntervalInt / 60;
        timeIntervalInt -= (minute * 60);
        
        components.minute = minute;
    }
    
    if (getSecond) {
        components.second = timeIntervalInt;
    }
    
    return components;
}

+ (NSString *)hhmmssStringFromTimeInterval:(NSTimeInterval)ti {
    
    NSDateComponents *components = [self getHour:YES minute:YES second:YES fromTimeInterval:ti];
        
    NSString *timeString = [NSString stringWithFormat:@"%02i:%02i:%02i", components.hour, components.minute, components.second];

    return timeString;
}

+ (NSString *)hhmmStringFromTimeInterval:(NSTimeInterval)ti {
    
    NSDateComponents *components = [self getHour:YES minute:YES second:NO fromTimeInterval:ti];
    
    NSString *timeString = [NSString stringWithFormat:@"%02i:%02i", components.hour, components.minute];
    
    return timeString;
    
}

+ (NSString *)mmssStringFromTimeInterval:(NSTimeInterval)ti {
    
    NSDateComponents *components = [self getHour:NO minute:YES second:YES fromTimeInterval:ti];
    
    NSString *timeString = [NSString stringWithFormat:@"%02i:%02i", components.minute, components.second];
    
    return timeString;

    
}

@end
