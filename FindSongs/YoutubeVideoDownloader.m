//
//  YoutubeVideoDownloader.m
//  AudioExporter
//
//  Created by Adrien Truong on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoutubeVideoDownloader.h"

@interface YoutubeVideoDownloader () <LBYouTubeExtractorDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, copy, readwrite) NSURL *youtubeURL;

@property (nonatomic, copy) NSURL *videoURL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) LBYouTubeExtractor *youtubeExtractor;

@property (nonatomic, strong) NSMutableData *videoData;
@property (nonatomic, strong) NSNumber *expectedVideoDataLengthNumber;

@property (nonatomic, assign, readwrite) float progress;

- (void)actuallyStartDownloading;

@end

@implementation YoutubeVideoDownloader

#pragma mark - Creating a Downloader

+ (YoutubeVideoDownloader *)videoDownloaderForYoutubeURL:(NSURL *)url completionHandler:(YoutubeVideoDownloaderCompletionHandler)handler
{
    
    YoutubeVideoDownloader *downloader = [[self alloc] initWithYoutubeURL:url];
    
    downloader.completionHandler = handler;
    
    return downloader;
    
}

- (id)initWithYoutubeURL:(NSURL *)youtubeURL
{
    
    self = [super init];
    
    if (self != nil) {
        
        self.youtubeURL = youtubeURL;
        self.videoQuality = LBYouTubeVideoQualityMedium;
        self.downloading = NO;
        
    }
    
    return self;
    
}

- (id)initWithYoutubeVideoID:(NSString *)videoID
{
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID];
    
    self = [self initWithYoutubeURL:[NSURL URLWithString:urlString]];
    
    return self;
    
}

#pragma mark - Public Methods

- (void)startDownloading
{
    
    self.downloading = YES;
    
    self.progress = 0;
    
    if (self.videoURL == nil) {
        
        self.youtubeExtractor = [[LBYouTubeExtractor alloc] initWithURL:self.youtubeURL quality:self.videoQuality];
        
        self.youtubeExtractor.delegate = self;
        
        [self.youtubeExtractor startExtracting];
                
    }
    else {
        
        [self actuallyStartDownloading];
        
    }
    
}

- (void)stopDownloading
{
    
    [self.youtubeExtractor stopExtracting];
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

#pragma mark - LBYoutubeExtractor Delegate Methods

- (void)youTubeExtractor:(LBYouTubeExtractor *)extractor didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL
{
    
    self.videoURL = videoURL;
    
    [self actuallyStartDownloading];
        
}

- (void)youTubeExtractor:(LBYouTubeExtractor *)extractor failedExtractingYouTubeURLWithError:(NSError *)error
{
    
    NSLog(@"failed extracting with error:%@", error);
    
    self.completionHandler(nil, error);
    
    self.downloading = NO;
    
}

@end
