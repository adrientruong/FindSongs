//
//  AppDelegate.m
//  FindSongs
//
//  Created by Adrien Truong on 12/25/12.
//  Copyright (c) 2012 Adrien Truong. All rights reserved.
//

#import "AppDelegate.h"
#import "FSYTVideoSearchWindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) FSYTVideoSearchWindowController *videoSearchWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.videoSearchWindowController = [[FSYTVideoSearchWindowController alloc] init];
    
    [self.videoSearchWindowController showWindow:nil];
    
}

@end
