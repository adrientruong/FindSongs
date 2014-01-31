//
//  FSGetSongFromYoutubeVideoTask.m
//  FindSongs
//
//  Created by Adrien Truong on 12/27/12.
//  Copyright (c) 2012 Adrien Truong. All rights reserved.
//

#import "FSGetSongFromYoutubeVideoTask.h"
#import "YoutubeVideoDownloader.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+UUID.h"
#import "EPSongLookup.h"

#define kActivityStringDownloading @"Downloading video.."
#define kActivityStringStripping @"Stripping audio..."
#define kActivityStringSaving @"Saving..."

@interface FSGetSongFromYoutubeVideoTask ()

@property (nonatomic, copy, readwrite) NSString *videoID;

@property (nonatomic, copy, readwrite) NSString *currentActivityString;

@property (nonatomic, strong) YoutubeVideoDownloader *videoDownloader;

@property (nonatomic, assign, getter = isDone) BOOL done;

@end

@implementation FSGetSongFromYoutubeVideoTask

- (id)initWithVideoID:(NSString *)videoID
{
    
    self = [super init];
    
    if (self != nil) {
        
        self.videoID = videoID;
        
    }
    
    return self;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"progress"]) {
        
        NSNumber *newNumber = [change objectForKey:NSKeyValueChangeNewKey];
        
        self.progress = [newNumber floatValue] * 0.9;
                        
    }
    
}

- (void)start
{
        
    self.currentActivityString = kActivityStringDownloading;
    
    self.videoDownloader = [[YoutubeVideoDownloader alloc] initWithYoutubeVideoID:self.videoID];
    
    __weak FSGetSongFromYoutubeVideoTask *weakSelf = self;
    
    /*
    [self observe:self.videoDownloader keyPath:@"progress" block:^(id observed, NSDictionary *dictionary) {
       
        NSNumber *newValue = [dictionary objectForKey:NSKeyValueChangeNewKey];
        
        self.progress = [newValue floatValue] * 0.9;
        
        NSLog(@"progress:%f", self.progress);
        
        
    }];
     */
    
    [self.videoDownloader addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    
    self.videoDownloader.completionHandler = ^(NSData *data, NSError *error) {
                
        weakSelf.progress = 0.9;
        
        if (data == nil) {
            
            if (weakSelf.completionHandler != nil) {
                
                weakSelf.completionHandler(NO, error);
                
            }
            
            NSLog(@"ERROR DOWNLOADING:%@", [error userInfo]);
        
            return;
            
        }
        
        weakSelf.currentActivityString = kActivityStringStripping;
        
        [weakSelf getAudioDataFromVideoData:data completionHandler:^(NSData *audioData) {
            
            [EPSongLookup lookupSongWithData:audioData completionHandler:^(NSDictionary *dictionary) {
                
                NSLog(@"Dictionary:%@", dictionary);
                
            }];
            
            weakSelf.progress = 0.95;
           
            weakSelf.currentActivityString = kActivityStringSaving;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
            
            if ([paths count] == 0) {
                
                NSLog(@"Could not find music directory!");
                
                return;
                
            }
            
            NSString *musicDirectory = [paths objectAtIndex:0];
            
            NSString *savePath = [NSString pathWithComponents:@[musicDirectory, @"iTunes", @"iTunes Media", @"Automatically Add to iTunes.localized", [NSString stringWithFormat:@"%@.m4a", weakSelf.songName]]];
                        
            NSError *writeError = nil;
            
            BOOL success = [data writeToFile:savePath options:NSDataWritingAtomic error:&writeError];
                    
            if (success == NO) {
                
                if (weakSelf.completionHandler != nil) {
                    
                    weakSelf.completionHandler(NO, writeError);
                    
                }
                
                NSLog(@"error occurred:%@", [writeError userInfo]);

                return;
                
            }
            else {
                
                weakSelf.progress = 1.00;
                
                if (weakSelf.completionHandler != nil) {
                    
                    weakSelf.completionHandler(YES, nil);
                    
                }
                
                weakSelf.done = YES;

            }
                        
        }];
        
    };
    
    [self.videoDownloader startDownloading];
            
}

#pragma mark - Private Methods

- (void)getAudioDataFromVideoData:(NSData *)videoData completionHandler:(void (^)(NSData *))completionHandler
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    if ([paths count] == 0) {
        
        NSLog(@"Error: no cache directory found!");
        
        return;
        
    }
    
    NSString *cachePath = [paths objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", [NSString UUID]];
    
    NSString *tempWritePath = [cachePath stringByAppendingPathComponent:fileName];
    
    [videoData writeToFile:tempWritePath atomically:YES];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:tempWritePath] options:nil];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    
    fileName = [NSString stringWithFormat:@"%@.mp4", [NSString UUID]];
    
    NSString *exportPath = [cachePath stringByAppendingPathComponent:fileName];
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    
    exportSession.outputURL = exportURL;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    
    [exportSession exportAsynchronouslyWithCompletionHandler: ^(void) {
        
        [[NSFileManager defaultManager] removeItemAtPath:tempWritePath error:nil];
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            
            NSData *data = [NSData dataWithContentsOfURL:exportURL];
            
            [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
            
            completionHandler(data);
            
        }
        else {
            
            completionHandler(nil);
            
            NSLog(@"Export failed:%@", exportSession.error);
            
        }
        
    }];
    
}



@end
