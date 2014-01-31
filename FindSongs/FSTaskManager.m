//
//  FSTaskManager.m
//  FindSongs
//
//  Created by Adrien Truong on 1/23/13.
//  Copyright (c) 2013 Adrien Truong. All rights reserved.
//

#import "FSTaskManager.h"
#import "FSGetSongFromYoutubeVideoTask.h"
#import "LBYouTubeExtractor.h"

@interface FSTaskManager ()

@property (nonatomic, strong) NSMutableArray *mutableTasks;
@property (nonatomic, strong) NSMutableArray *mutableActiveTasks;

@property (nonatomic, strong) NSMutableArray *taskQueue;

@end

@implementation FSTaskManager

+ (FSTaskManager *)sharedTaskManager
{
    
    static FSTaskManager *taskManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        taskManager = [[self alloc] init];
        
    });
    
    return taskManager;
    
}

- (id)init
{
    
    self = [super init];
    
    if (self != nil) {
        
        self.mutableTasks = [NSMutableArray array];
    
        self.mutableActiveTasks = [NSMutableArray array];
        
        self.taskQueue = [NSMutableArray array];
        
        self.maximumActiveTasks = 1;
        
    }
    
    return self;
    
}

- (void)addTask:(FSGetSongFromYoutubeVideoTask *)task
{
    
    FSGetSongFromYoutubeVideoTaskCompletionHandler completionHandler = task.completionHandler;
    
    __weak FSGetSongFromYoutubeVideoTask *weakTask = task;
    
    task.completionHandler = ^(BOOL success, NSError *error) {
        
        [self.mutableActiveTasks removeObjectIdenticalTo:weakTask];
        
        if (completionHandler != nil) {
            
            completionHandler(success, error);
            
        }
        
        if ([self.taskQueue count] > 0) {
         
            FSGetSongFromYoutubeVideoTask *nextTask = [self.taskQueue objectAtIndex:0];
            
            [self.taskQueue removeObjectAtIndex:0];

            int64_t delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                
                [self.mutableActiveTasks addObject:nextTask];
                
                [nextTask start];

            });
            
        }
        
    };
    
    if ([self.mutableActiveTasks count] + 1 <= self.maximumActiveTasks) {
        
        [self.mutableActiveTasks addObject:task];

        [task start];
        
    }
    else {
        
        [self.taskQueue addObject:task];
        
    }
    
}

- (NSArray *)tasks
{
    
    return self.mutableTasks;
    
}

- (NSArray *)activeTasks
{
    
    return self.mutableActiveTasks;
    
}
@end
