//
//  YoutubeVideoDownloader.m
//  AudioExporter
//
//  Created by Adrien Truong on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoutubeVideoDownloader.h"
#import <XCDYouTubeExtractor.h>

@interface YoutubeVideoDownloader () <NSURLConnectionDataDelegate>

@property (nonatomic, copy, readwrite) NSString *videoID;

@property (nonatomic, copy) NSURL *videoURL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) XCDYouTubeExtractor *youtubeExtractor;

@property (nonatomic, strong) NSMutableData *videoData;
@property (nonatomic, strong) NSNumber *expectedVideoDataLengthNumber;

@property (nonatomic, assign, readwrite) float progress;

- (void)actuallyStartDownloading;

@end

@implementation YoutubeVideoDownloader

#pragma mark - Creating a Downloader

+ (YoutubeVideoDownloader *)videoDownloaderForYoutubeVideoID:(NSString *)videoID completionHandler:(YoutubeVideoDownloaderCompletionHandler)handler
{
    
    YoutubeVideoDownloader *downloader = [[self alloc] initWithYoutubeVideoID:videoID];
    
    downloader.completionHandler = handler;
    
    return downloader;
    
}

- (id)initWithYoutubeVideoID:(NSString *)videoID
{
    
    self = [super init];
    
    if (self != nil) {
        
        self.videoID = videoID;
        self.videoQuality = XCDYouTubeVideoQualityHD720;
        self.downloading = NO;
        
    }
    
    return self;
    
}

#pragma mark - Public Methods

- (void)startDownloading
{
    
    self.downloading = YES;
    
    self.progress = 0;
    
    if (self.videoURL == nil) {
        self.youtubeExtractor = [[XCDYouTubeExtractor alloc] initWithVideoIdentifier:self.videoID];
        [self.youtubeExtractor startWithCompletionHandler:^(NSDictionary *info, NSError *error) {
            if (info == nil) {
                self.downloading = NO;
                return;
            }
            
            self.videoURL = info[@(self.videoQuality)];
            [self actuallyStartDownloading];
        }];
        
    }
    else {
        
        [self actuallyStartDownloading];
        
    }
    
}

- (void)stopDownloading
{
    
    [self.youtubeExtractor cancel];
    [self.connection cancel];
    
    self.downloading = NO;
    
}

- (float)progress
{
    
    if ([self.expectedVideoDataLengthNumber floatValue] > 0) {
        
        return self.videoData.length / [self.expectedVideoDataLengthNumber floatValue];

    }
    else if ([self.expectedVideoDataLengthNumber floatValue] == NSURLResponseUnknownLength) {
        
        return NSURLResponseUnknownLength;
        
    }
    else {
        
        return 0;
        
    }
    
}

#pragma mark - Private Methods

- (void)actuallyStartDownloading
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.videoURL];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (self.connection == nil) {
        
        NSDictionary *errorDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Could not download.", NSLocalizedDescriptionKey, nil];
        
        NSError *error = [NSError errorWithDomain:@"YoutubeVideoDownloader" code:0 userInfo:errorDictionary];
        
        self.completionHandler(nil, error);
        
    }
    else {
        
        [self.connection start];
        
    }

}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    self.expectedVideoDataLengthNumber = [NSNumber numberWithLongLong:response.expectedContentLength];
    
    self.videoData = [NSMutableData dataWithCapacity:response.expectedContentLength];
            
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [self.videoData appendData:data];
    
    if ([self.expectedVideoDataLengthNumber floatValue] > 0) {
        
        self.progress = self.videoData.length / [self.expectedVideoDataLengthNumber floatValue];
        
    }
    else if ([self.expectedVideoDataLengthNumber floatValue] == NSURLResponseUnknownLength) {
        
        self.progress = NSURLResponseUnknownLength;
        
    }
      
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    self.completionHandler(self.videoData, nil);
    
    self.connection = nil;
    
    self.downloading = NO;
    
    self.expectedVideoDataLengthNumber = [NSNumber numberWithUnsignedInteger:self.videoData.length];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    self.completionHandler(nil, error);
    
    self.connection = nil;
    
    self.downloading = NO;
    
}

@end
