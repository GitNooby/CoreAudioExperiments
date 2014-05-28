//
//  main.m
//  CoreAudio_ToneGenerator_Exp02
//
//  Created by Kai Zou on 2014-05-27.
//  Copyright (c) 2014 com.personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100
#define DURATION 2.0
#define FILENAME_FORMAT @"%0.3f-square.aif"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc < 2) {
            printf ("Usage: CoreAudio_ToneGenerator_Exp02 n\n(where n is tone in Hz)");
            return 0;
        }
        
        double hz = atof(argv[1]);
        assert(hz > 0);
        
        NSString *fileName = [NSString stringWithFormat:FILENAME_FORMAT, hz];
        NSString *filePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:fileName];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        
        // preparing the audio format
        AudioStreamBasicDescription asbd;
        memset(&asbd, 0, sizeof(asbd));
        asbd.mSampleRate = SAMPLE_RATE;
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        asbd.mBitsPerChannel = 16;
        asbd.mChannelsPerFrame = 1;
        asbd.mFramesPerPacket = 1;
        asbd.mBytesPerFrame = 2;
        asbd.mBytesPerPacket = 2;
        
        // setup the output file
        AudioFileID audioFile;
        OSStatus audioErr = noErr;
        audioErr = AudioFileCreateWithURL((__bridge CFURLRef)fileUrl, kAudioFileAIFFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
        assert(audioErr == noErr);
        
        // start to write samples
        long maxSampleCount = SAMPLE_RATE * DURATION;
        long sampleCount = 0;
        UInt32 bytesToWrite = 2;
        double wavelengthInSamples = SAMPLE_RATE / hz;
        
        while (sampleCount < maxSampleCount) {
            for (int i=0; i<wavelengthInSamples; i++) {
                // square wave
                SInt16 sample;
                if (i < wavelengthInSamples / 2) {
                    sample = CFSwapInt16HostToBig(SHRT_MAX);
                } else {
                    sample = CFSwapInt16HostToBig(SHRT_MIN);
                }
                audioErr = AudioFileWriteBytes(audioFile, false, sampleCount*2, &bytesToWrite, &sample);
                assert(audioErr == noErr);
                sampleCount++;
            }
        }
        
        audioErr = AudioFileClose(audioFile);
        assert (audioErr == noErr);
        NSLog(@"wrote %ld samples", sampleCount);
        
        
    }
    return 0;
}

