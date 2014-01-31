//
//  EPSongLookup.m
//  FindSongs
//
//  Created by Adrien Truong on 5/12/13.
//  Copyright (c) 2013 Adrien Truong. All rights reserved.
//

#import "EPSongLookup.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudio.h>
#import "CAStreamBasicDescription.h"
#import "CAXException.h"
#include <zlib.h>
#include <string>
#include "Codegen_wrapper.h"
#import "AFNetworking.h"
#import "NSURL+SystemDirectories.h"
#import "NSString+UUID.h"
#include "Codegen.h"

@implementation EPSongLookup

+ (void)lookupSongWithData:(NSData *)songData completionHandler:(EPSongLookupCompletionHandler)completionHandler
{
    
    EPSongLookup *lookup = [[[self class] alloc] init];
    
    lookup.songData = songData;
    lookup.completionHandler = completionHandler;
    
    [lookup start];
    
}

- (void)start
{
 
    NSURL *saveURL = [[NSURL cacheDirectoryURL] URLByAppendingPathComponent:[NSString UUID]];
    
    BOOL success = [self.songData writeToURL:saveURL atomically:YES];
        
    CFURLRef inputFileURL = (__bridge CFURLRef)saveURL;
    ExtAudioFileRef inputFileRef;
    ExtAudioFileOpenURL(inputFileURL, &inputFileRef);
    
    
    // setup an mono LPCM format description for conversion & set as the input file's client format
    Float64 sampleRate = 11025;
    CAStreamBasicDescription outputFormat;
    outputFormat.mSampleRate = sampleRate;
    outputFormat.mFormatID = kAudioFormatLinearPCM;
    outputFormat.mChannelsPerFrame = 1;
    outputFormat.mBitsPerChannel = 32;
    outputFormat.mBytesPerPacket = outputFormat.mBytesPerFrame = 4 * outputFormat.mChannelsPerFrame;
    outputFormat.mFramesPerPacket = 1;
    outputFormat.mFormatFlags =  kAudioFormatFlagsNativeFloatPacked;
    
    ExtAudioFileSetProperty(inputFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(outputFormat), &outputFormat);
    
    
    // read the first 30 seconds of the file into a buffer
    NSInteger secondsToDecode = 30;
    UInt32 lpcm30SecondsBufferSize = sizeof(Float32) * sampleRate * secondsToDecode; // for mono, multi channel would require * ChannelsPerFrame
    Float32 *lpcm30SecondsBuffer = (Float32 *)malloc(lpcm30SecondsBufferSize);
    
    
    AudioBufferList audioBufferList;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0].mNumberChannels = 1;
    audioBufferList.mBuffers[0].mDataByteSize = lpcm30SecondsBufferSize;
    audioBufferList.mBuffers[0].mData = lpcm30SecondsBuffer;
    
    UInt32 numberOfFrames = sampleRate * secondsToDecode;
    NSLog(@"Expect to read %d frames", numberOfFrames);
    //NSLogOSStatus(ExtAudioFileRead(inputFileRef, &numberOfFrames, &audioBufferList));
    NSLog(@"Actually read %d frames", numberOfFrames);
    
    // get the fingerprint code
    Codegen *codegen = new Codegen(lpcm30SecondsBuffer, numberOfFrames, 0);
    NSLog(@"%s", codegen->getCodeString().c_str());
    NSString *fingerprintString = [NSString stringWithCString:codegen->getCodeString().c_str() encoding:NSUTF8StringEncoding];
    
    // look up echonest
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/identify?api_key=%@&bucket=id:musicbrainz&bucket=tracks&version=4.11&code=%@", kAPIKey, fingerprintString]];
    
    NSLog(@"finger print:%@", fingerprintString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
        self.completionHandler(JSON);
        
        [[NSFileManager defaultManager] removeItemAtURL:saveURL error:nil];
        
    } failure:nil];
    
    [operation start];
    
    free(lpcm30SecondsBuffer);
    ExtAudioFileDispose(inputFileRef);
    
}

@end
