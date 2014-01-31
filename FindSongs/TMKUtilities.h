//
//  TMKUtilities.h
//  Tabata
//
//  Created by Adrien Truong on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMKUtilities : NSObject

+ (NSDateComponents *)getHour:(BOOL)getHour minute:(BOOL)getMinute second:(BOOL)getSecond fromTimeInterval:(NSTimeInterval)timeInterval;

/* Discussion
 
 Passing in nil for one of the parameters bumps up the next unit. For example, if you were to pass in 60 seconds, and pass in NO for minute, you would get 60 for seconds. But if you were to pass in YES for minute, you'd get 1 for minute and 0 for seconds.
 
 */

+ (NSString *)hhmmssStringFromTimeInterval:(NSTimeInterval)ti;
+ (NSString *)hhmmStringFromTimeInterval:(NSTimeInterval)ti;
+ (NSString *)mmssStringFromTimeInterval:(NSTimeInterval)ti;

@end
