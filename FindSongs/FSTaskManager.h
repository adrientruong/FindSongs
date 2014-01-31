//
//  FSTaskManager.h
//  FindSongs
//
//  Created by Adrien Truong on 1/23/13.
//  Copyright (c) 2013 Adrien Truong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  FSGetSongFromYoutubeVideoTask;

@interface FSTaskManager : NSObject

@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) NSArray *activeTasks;

@property (nonatomic, assign) NSInteger maximumActiveTasks;

+ (FSTaskManager *)sharedTaskManager;

- (void)addTask:(FSGetSongFromYoutubeVideoTask *)task;

@end
