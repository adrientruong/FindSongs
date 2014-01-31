//
//  EPSongLookup.h
//  FindSongs
//
//  Created by Adrien Truong on 5/12/13.
//  Copyright (c) 2013 Adrien Truong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAPIKey @"FMKWBV1LZOWFR4QSC"

typedef void (^EPSongLookupCompletionHandler)(NSDictionary *result);

@interface EPSongLookup : NSObject

@property (nonatomic, strong) NSData *songData;
@property (nonatomic, copy) EPSongLookupCompletionHandler completionHandler;

+ (void)lookupSongWithData:(NSData *)songData completionHandler:(EPSongLookupCompletionHandler)completionHandler;

- (void)start;

@end
