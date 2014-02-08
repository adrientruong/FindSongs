//
//  YoutubeVideoDownloader.h
//  AudioExporter
//
//  Created by Adrien Truong on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCDYouTubeConstants.h>

typedef void (^YoutubeVideoDownloaderCompletionHandler)(NSData *videoData, NSError *error);

@interface YoutubeVideoDownloader : NSObject

@property (nonatomic, copy, readonly) NSString *videoID;
@property (nonatomic, copy) YoutubeVideoDownloaderCompletionHandler completionHandler;
@property (nonatomic, assign) XCDYouTubeVideoQuality videoQuality;
@property (nonatomic, assign, getter = isDownloading) BOOL downloading;
@property (nonatomic, assign, readonly) float progress;

+ (YoutubeVideoDownloader *)videoDownloaderForYoutubeVideoID:(NSString *)videoID completionHandler:(YoutubeVideoDownloaderCompletionHandler)handler;

- (id)initWithYoutubeVideoID:(NSString *)videoID;

- (void)startDownloading;
- (void)stopDownloading;

@end
