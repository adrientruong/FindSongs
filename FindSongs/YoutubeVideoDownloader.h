//
//  YoutubeVideoDownloader.h
//  AudioExporter
//
//  Created by Adrien Truong on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBYouTubeExtractor.h"

typedef void (^YoutubeVideoDownloaderCompletionHandler)(NSData *videoData, NSError *error);

@interface YoutubeVideoDownloader : NSObject

@property (nonatomic, copy, readonly) NSURL *youtubeURL;
@property (nonatomic, copy) YoutubeVideoDownloaderCompletionHandler completionHandler;
@property (nonatomic, assign) LBYouTubeVideoQuality videoQuality;
@property (nonatomic, assign, getter = isDownloading) BOOL downloading;
@property (nonatomic, assign, readonly) float progress;

+ (YoutubeVideoDownloader *)videoDownloaderForYoutubeURL:(NSURL *)url completionHandler:(YoutubeVideoDownloaderCompletionHandler)handler;

- (id)initWithYoutubeURL:(NSURL *)youtubeURL;
- (id)initWithYoutubeVideoID:(NSString *)videoID;


- (void)startDownloading;
- (void)stopDownloading;

@end
