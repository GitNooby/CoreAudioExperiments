//
//  main.m
//  CoreAudio_GrabMetaData_Exp01
//
//  Created by Kai Zou on 2014-05-27.
//  Copyright (c) 2014 com.personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        if (argc < 2) {
            printf("Usage : CoreAudio_GrabMetaData_Exp01 /full/path/to/audiofile\n");
            return -1;
        }
        
        NSString *audioFilePath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
        NSURL *audioURL = [NSURL fileURLWithPath:audioFilePath];
        AudioFileID audioFile;
        OSStatus theErr = noErr;
        theErr = AudioFileOpenURL((__bridge CFURLRef)audioURL,
                                  kAudioFileReadPermission,
                                  0,
                                  &audioFile);
        assert(theErr == noErr);
        
        UInt32 propertySize = 0;
        theErr = AudioFileGetPropertyInfo(audioFile,
                                          kAudioFilePropertyInfoDictionary,
                                          &propertySize,
                                          0);
        assert(theErr == noErr);
        
//        char* rawID3Tag = (char*)malloc(propertySize);
        
//        theErr = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &propertySize, rawID3Tag);
        CFDictionaryRef piDict = nil;
        UInt32 piDataSize = sizeof(piDict);
        
        //  Populates a CFDictionary with the ID3 tag properties
        theErr = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
        if(theErr != noErr) {
            NSLog(@"AudioFileGetProperty failed for property info dictionary");
            return 0;
        }
        assert(theErr == noErr);
        
        NSDictionary *nsDic = (__bridge NSDictionary*)piDict;
        
        NSLog(@"dictionary: %@", nsDic);
//        free(rawID3Tag);
        CFRelease(piDict);
        theErr = AudioFileClose(audioFile);
        assert(theErr == noErr);
        
    }
    return 0;
}

