//
//  FSYTVideoSearchWindowController.m
//  FindSongs
//
//  Created by Adrien Truong on 12/25/12.
//  Copyright (c) 2012 Adrien Truong. All rights reserved.
//

#import "FSYTVideoSearchWindowController.h"
#import "LBYouTubeExtractor.h"
#import <AVFoundation/AVFoundation.h>
#import "YoutubeVideoDownloader.h"
#import <QuartzCore/QuartzCore.h>
#import "JKSMoviePlayerController.h"
#import "FSGetSongFromYoutubeVideoTask.h"
#import "BDDiscreteProgressCell.h"
#import "FSTaskManager.h"

@interface FSYTVideoSearchWindowController () <LBYouTubeExtractorDelegate, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSArrayController *searchResultsArrayController;
@property (nonatomic, weak) IBOutlet NSTableView *searchResultsTableView;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, weak) IBOutlet NSView *moviePlayerContainerView;

@property (nonatomic, weak) IBOutlet NSArrayController *getSongTasksArrayController;
@property (nonatomic, weak) IBOutlet NSTableView *getSongTasksTableView;

@property (nonatomic, strong) JKSMoviePlayerController *moviePlayerController;

@property (nonatomic, strong) NSArray *searchResults;

@property (nonatomic, strong) LBYouTubeExtractor *youtubeExtractor;

@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, strong) YoutubeVideoDownloader *downloader;

- (IBAction)userDidHitEnterOnSearch:(NSSearchField *)searchField;
- (IBAction)userDidClickDownloadButton:(NSButtonCell *)cell;

@end

@implementation FSYTVideoSearchWindowController

- (id)init
{
    
    self = [super initWithWindowNibName:@"FSYTVideoSearchWindow"];
    
    if (self != nil) {
        
        self.window.title = @"Find Songs";
        
    }
    
    return self;
    
}

- (GDataServiceGoogleYouTube *)youTubeService {
    static GDataServiceGoogleYouTube* _service = nil;
    
    if (!_service) {
        _service = [[GDataServiceGoogleYouTube alloc] init];
        
        [_service setUserAgent:@"A Cool App!"];
        
    }
    
    // fetch unauthenticated
    [_service setUserCredentialsWithUsername:nil
                                    password:nil];
    
    return _service;
}


- (void)windowDidLoad
{
    
    [super windowDidLoad];
    
    self.searchResultsTableView.doubleAction = @selector(userDidTapCell);
        
}

- (void)searchWithSearchString:(NSString *)string
{
    
    self.selectedRow = -1;
    
    GDataServiceGoogleYouTube *service = [self youTubeService];
    
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:nil];
    
    GDataQueryYouTube* query = [GDataQueryYouTube  youTubeQueryWithFeedURL:feedURL];
    
    [query setVideoQuery:string];
        
    [query setMaxResults:50];
    
    [service fetchFeedWithQuery:query delegate:self didFinishSelector:@selector(requestFinishForYouTube:finishedWithFeed:error:)];
    
}

- (void)requestFinishForYouTube:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error
{
    NSArray *objects = [self.searchResultsArrayController arrangedObjects];
    NSRange range = NSMakeRange(0, [objects count]);
    
    [self.searchResultsArrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    for (GDataEntryYouTubeVideo *entry in [feed entries]) {
        
        [self.searchResultsArrayController addObject:entry];
        
    }
    
}

- (void)userDidTapCell
{
    
    if (self.selectedRow == self.searchResultsTableView.clickedRow) {
        
        return;
        
    }
    
    self.selectedRow = self.searchResultsTableView.clickedRow;
    
    GDataEntryYouTubeVideo *video = [[self.searchResultsArrayController arrangedObjects] objectAtIndex:self.selectedRow];
    
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    
    NSString *videoID = [mediaGroup videoID];
        
    self.youtubeExtractor = [[LBYouTubeExtractor alloc] initWithID:videoID quality:LBYouTubeVideoQualityLarge];
    
    self.youtubeExtractor.delegate = self;
    
    [self.youtubeExtractor startExtracting];
        
}

- (IBAction)userDidHitEnterOnSearch:(NSSearchField *)searchField
{
    
    [self searchWithSearchString:[self.searchField stringValue]];
    
}

- (IBAction)userDidClickDownloadButton:(NSTableView *)tableView;
{
    
    GDataEntryYouTubeVideo *video = [[self.searchResultsArrayController arrangedObjects] objectAtIndex:tableView.clickedRow];
    
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    
    NSString *videoID = [mediaGroup videoID];
    
    for (FSGetSongFromYoutubeVideoTask *task in [self.getSongTasksArrayController arrangedObjects]) {
        
        if ([task.videoID isEqualToString:videoID])  {
            
            NSAlert *alert = [NSAlert alertWithMessageText:@"PEBKAC Error" defaultButton:@"I'm an idiot." alternateButton:nil otherButton:nil informativeTextWithFormat:@"You already downloaded this song you twat."];
            
            [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
            
            return;
            
        }
        
    }
    
    FSGetSongFromYoutubeVideoTask *getSongTask = [[FSGetSongFromYoutubeVideoTask alloc] initWithVideoID:videoID];
    
    getSongTask.songName = [[video title] stringValue];
    
    [[FSTaskManager sharedTaskManager] addTask:getSongTask];
        
    [self.getSongTasksArrayController addObject:getSongTask];
    
}

#pragma mark - LBYoutubeExtractor Delegate Methods

- (void)youTubeExtractor:(LBYouTubeExtractor *)extractor didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL
{
    
    [self.moviePlayerController.view removeFromSuperview];
    
    self.moviePlayerController = [[JKSMoviePlayerController alloc] initWithContentURL:videoURL];
    self.moviePlayerController.scalingMode = JKSMoviePlayerScalingResizeAspect;
        
    [self.moviePlayerContainerView addSubview:self.moviePlayerController.view];
    
    NSView *movieView = self.moviePlayerController.view;

    [self.moviePlayerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[movieView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(movieView)]];
    [self.moviePlayerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[movieView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(movieView)]];
    
    [self.moviePlayerController play];
    
    if (extractor == self.youtubeExtractor) {
        
        self.youtubeExtractor = nil;
        
    }
        
}

- (void)youTubeExtractor:(LBYouTubeExtractor *)extractor failedExtractingYouTubeURLWithError:(NSError *)error
{
   
    if (extractor == self.youtubeExtractor) {
        
        self.youtubeExtractor = nil;
        
    }
    
    NSLog(@"Failed to extract URL for playback:%@", [error userInfo]);
    
}

#pragma mark - NSTableViewDelegate


- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    return NO;
    
}

@end
