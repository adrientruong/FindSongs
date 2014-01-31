//
//  FSGetSongFromYoutubeVideoTask.h
//  FindSongs
//
//  Created by Adrien Truong on 12/27/12.
//  Copyright (c) 2012 Adrien Truong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FSGetSongFromYoutubeVideoTaskCompletionHandler)(BOOL success, NSError *error);

@interface FSGetSongFromYoutubeVideoTask : NSObject

@property (nonatomic, copy, readonly) NSString *videoID;

@property (nonatomic, copy, readonly) NSString *currentActivityString;

@property (nonatomic, copy) NSString *songName;

@property (nonatomic, copy) FSGetSongFromYoutubeVideoTaskCompletionHandler completionHandler;

@property (nonatomic, assign) float progress;

- (id)initWithVideoID:(NSString *)videoID;

- (void)start;

@end
