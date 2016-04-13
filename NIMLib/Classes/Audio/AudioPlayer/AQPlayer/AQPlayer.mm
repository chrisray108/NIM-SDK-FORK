/*
 
    File: AQPlayer.mm
Abstract: n/a
 Version: 2.5

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2012 Apple Inc. All Rights Reserved.

 
*/


#include "AQPlayer.h"
#import <AVFoundation/AVAudioSession.h>

namespace NIM {

NSString *const NIMNotificationAQPlayerError       = @"aq_player_error";
NSString *const NIMNotificationAQPlayerEnd         = @"aq_player_end";
NSString *const kNIMNotificationAQPlayerInterrBegin = @"aq_player_interrupt_begin";
NSString *const kNIMNotificationAQPlayerInterrEnd   = @"aq_player_interrupt_end";


void AQPlayer::AQBufferCallback(void *					inUserData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inCompleteAQBuffer) 
{
	AQPlayer *THIS = (AQPlayer *)inUserData;

	if (THIS->mIsDone) return;

	UInt32 numBytes;
	UInt32 nPackets = THIS->GetNumPacketsToRead();
	OSStatus result = AudioFileReadPackets(THIS->GetAudioFileID(), false, &numBytes, inCompleteAQBuffer->mPacketDescriptions,
                                           THIS->GetCurrentPacket(), &nPackets,
										   inCompleteAQBuffer->mAudioData);
    if (result) {
        NSError *nsError = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
        NIMLogErr(@"file read packets failed:%s", [[nsError description] UTF8String]);
        [[NSNotificationCenter defaultCenter] postNotificationName:NIMNotificationAQPlayerError object:nil];
    }

	if (nPackets > 0) {
        NIMLogApp(@"read packet num of packets:%d, num of bytes:%d", nPackets, numBytes);
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;
		inCompleteAQBuffer->mPacketDescriptionCount = nPackets;		
		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
		THIS->mCurrentPacket = (THIS->GetCurrentPacket() + nPackets);
	} 
	
	else 
	{
		if (THIS->IsLooping())
		{
			THIS->mCurrentPacket = 0;
			AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
		}
		else
		{
			// stop
			THIS->mIsDone = true;
			AudioQueueStop(inAQ, false);
		}
	}
}

void AQPlayer::isRunningProc (  void *              inUserData,
								AudioQueueRef           inAQ,
								AudioQueuePropertyID    inID)
{
	AQPlayer *THIS = (AQPlayer *)inUserData;
	UInt32 size = sizeof(THIS->mIsRunning);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &THIS->mIsRunning, &size);
	
	if (result == noErr) {
        if (!THIS->mIsRunning) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NIMNotificationAQPlayerEnd object:nil];
        }
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NIMNotificationAQPlayerError object:nil];
    }
		
}

void AQPlayer::CalculateBytesForTime (CAStreamBasicDescription & inDesc, UInt32 inMaxPacketSize,
                                      Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
{
	// we only use time here as a guideline
	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
	
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	// we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}

AQPlayer::AQPlayer() :
	mQueue(0),
	mAudioFile(0),
	mFilePath(NULL),
	mIsRunning(false),
	mIsInitialized(false),
	mNumPacketsToRead(0),
	mCurrentPacket(0),
	mIsDone(false),
	mIsLooping(false),
    mIsCodecPolicyPreferSoftware(false){ }

AQPlayer::~AQPlayer() 
{
	DisposeQueue(true);
}


OSStatus AQPlayer::StartQueue(CFStringRef filePath, BOOL inResume /*= false*/)
{
    NSError *err;
    BOOL success = [[AVAudioSession sharedInstance] setActive:YES error:&err];
    if (!success)
    {
        NIMLogErr(@
                 "Error: Set Session Active Failed Error Code :%@",
                 [err localizedDescription]);
    }
    OSStatus error = noErr;
	// if we have a file but no queue, create one now
	if (mQueue == NULL) {
        if (!CreateQueueForFile(filePath)) {
            error = -1;
            return error;
        }
    }
	
	mIsDone = false;
	
	// if we are not resuming, we also should restart the file read index
	if (!inResume) {
		mCurrentPacket = 0;

        // prime the queue with some data before starting
        for (int i = 0; i < kNumberBuffers; ++i) {
            AQBufferCallback (this, mQueue, mBuffers[i]);			
        }
    }
	error =  AudioQueueStart(mQueue, NULL);
    if (error == noErr) {
        mIsRunning = true;
    }else if (error == kAudioConverterErr_HardwareInUse) {
        mIsCodecPolicyPreferSoftware = true;
    }
    
    return error;
}
    
float   AQPlayer::GetPeakPowerDB()
{
    if (!mIsRunning || mQueue == 0)
    {
        return 0;
    }
    float value = 0;
    UInt32 dataSz = sizeof(AudioQueueLevelMeterState) * mDataFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *state = (AudioQueueLevelMeterState *)malloc(dataSz);
    OSStatus status = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeterDB, state,
                                            &dataSz);
    if (status == noErr)
    {
        for (int i = 0; i < mDataFormat.mChannelsPerFrame; i++) {
            value += state[i].mPeakPower;
        }
    }
    free(state);
    return value;
}

float   AQPlayer::GetAveragePowerDB()
{
    if (!mIsRunning || mQueue == 0)
    {
        return 0;
    }
    float value = 0;
    UInt32 dataSz = sizeof(AudioQueueLevelMeterState) * mDataFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *state = (AudioQueueLevelMeterState *)malloc(dataSz);
    OSStatus status = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeterDB, state,
                                            &dataSz);
    if (status == noErr)
    {
        for (int i = 0; i < mDataFormat.mChannelsPerFrame; i++) {
            value += state[i].mAveragePower;
        }
    }
    free(state);
    return value;
}

double   AQPlayer::GetCurrentTime()
{
    if (!mIsRunning || mQueue == 0) {
        return 0;
    }
    AudioTimeStamp timeStamp;
    AudioQueueGetCurrentTime(mQueue, NULL, &timeStamp, NULL);
    return timeStamp.mSampleTime / mDataFormat.mSampleRate;
}

OSStatus AQPlayer::StopQueue()
{
    mIsDone = true;
    
	OSStatus result = AudioQueueStop(mQueue, true);
	if (result) {
        NSError *nsError = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
        NIMLogErr(@
               "stopping queue failed, error code:%s", [[nsError description] UTF8String]);
    }

	return result;
}

OSStatus AQPlayer::PauseQueue()
{
	OSStatus result = AudioQueuePause(mQueue);
    if (result) {
        NSError *nsError = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
        NIMLogErr(@
               "pauseing queue failed, error code:%s", [[nsError description] UTF8String]);
    }
	return result;
}

OSStatus AQPlayer::ResumeQueue(CFStringRef filePath)
{
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    OSStatus result = AudioQueueGetProperty (mQueue, kAudioQueueProperty_IsRunning, &isRunning, &size);
    if ((result == noErr) && (!isRunning)) {
        NIMLogApp(@"Resuming from pause, but the queue is already stopped, so no need to contine");
        return noErr;
    }
    return StartQueue(filePath, true);
}

bool AQPlayer::CreateQueueForFile(CFStringRef inFilePath)
{	
	CFURLRef sndFile = NULL; 

	try {
		if (mFilePath == NULL)
		{
			mIsLooping = false;
			
			sndFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, inFilePath, kCFURLPOSIXPathStyle, false);
			if (!sndFile) {
                NIMLogErr(@ "can't parse file path");
                return false;
            }
			
            OSStatus result = AudioFileOpenURL (sndFile, kAudioFileReadPermission, 0/*inFileTypeHint*/, &mAudioFile);
            if (result) {
                result = AudioFileOpenURL(sndFile, kAudioFileReadPermission, kAudioFileWAVEType, &mAudioFile);
                CFRelease(sndFile); // release sndFile here to quiet analyzer
                if (result) {
                    NIMLogErr(@ "can't open file");
                    XThrowIfError(result, "can't open file");
                }else {
                    NIMLogApp(@"raw pcm data, have no sense of shame at all");
                }
            }else {
                CFRelease(sndFile);
            }
            
			UInt32 size = sizeof(mDataFormat);
            result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyDataFormat, &size, &mDataFormat);
            if (result) {
                NIMLogErr(@ "can't get file's data format");
                XThrowIfError(result, "can't get file's data format");
            }
			mFilePath = CFStringCreateCopy(kCFAllocatorDefault, inFilePath);
		}
		SetupNewQueue();		
    }
	catch (CAXException e) {
		char buf[256];
		//fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        NIMLogErr(@
               "CAXException, error:%s (%s)", e.mOperation, e.FormatError(buf));
        return false;
	}
    
    return true;
}

void AQPlayer::SetupNewQueue()
{
    OSStatus result;
    result = AudioQueueNewOutput(&mDataFormat, AQPlayer::AQBufferCallback, this,
                                 CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &mQueue);
    if (result) {
        NIMLogErr(@ "AudioQueueNew failed");
        XThrowIfError(result, "AudioQueueNew failed");
    }
	UInt32 bufferByteSize;
	// we need to calculate how many packets we read at a time, and how big a buffer we need
	// we base this on the size of the packets in the file and an approximate duration for each buffer
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
	UInt32 maxPacketSize;
	UInt32 size = sizeof(maxPacketSize);
	result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyPacketSizeUpperBound,
                         &size, &maxPacketSize);
    if (result) {
        NIMLogErr(@ "couldn't get file's max packet size");
        XThrowIfError(result, "couldn't get file's max packet size");
    }
	
	// adjust buffer size to represent about a half second of audio based on this format
	CalculateBytesForTime (mDataFormat, maxPacketSize, kBufferDurationSeconds, &bufferByteSize, &mNumPacketsToRead);

		//printf ("Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)mNumPacketsToRead);
	
	// (2) If the file has a cookie, we should get it and set it on the AQ
	size = sizeof(UInt32);
	result = AudioFileGetPropertyInfo (mAudioFile, kAudioFilePropertyMagicCookieData, &size, NULL);
	
	if (!result && size) {
		char* cookie = new char [size];		
		AudioFileGetProperty (mAudioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
		AudioQueueSetProperty(mQueue, kAudioQueueProperty_MagicCookie, cookie, size);
		delete [] cookie;
	}
	
	// channel layout?
	result = AudioFileGetPropertyInfo(mAudioFile, kAudioFilePropertyChannelLayout, &size, NULL);
	if (result == noErr && size > 0) {
		AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
        
        result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyChannelLayout, &size, acl);
        if (result) {
            free(acl);
            NIMLogErr(@"get audio file's channel layout");
            XThrowIfError(result, "get audio file's channel layout");
        }
        
        result = AudioQueueSetProperty(mQueue, kAudioQueueProperty_ChannelLayout, acl, size);
        if (result){
            free(acl);
            NIMLogErr(@"set channel layout on queue");
            XThrowIfError(result, "set channel layout on queue");
        }
		
        free(acl);
        
        UInt32 val = mIsCodecPolicyPreferSoftware ? kAudioQueueHardwareCodecPolicy_PreferSoftware :
                                                        kAudioQueueHardwareCodecPolicy_PreferHardware;
        result = AudioQueueSetProperty(mQueue, kAudioQueueProperty_HardwareCodecPolicy, &val, sizeof(val));
        if (result) {
            NIMLogErr(@ "set hardware codec policy");
            XThrowIfError(result, "set hardware codec policy");
        }
    }
	
	result = AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, isRunningProc, this);
    if (result) {
        NIMLogErr(@ "adding property listener");
        XThrowIfError(result, "adding property listener");
    }
	
	bool isFormatVBR = (mDataFormat.mBytesPerPacket == 0 || mDataFormat.mFramesPerPacket == 0);
	for (int i = 0; i < kNumberBuffers; ++i) {
		result =  AudioQueueAllocateBufferWithPacketDescriptions(mQueue, bufferByteSize,
                                                                 (isFormatVBR ? mNumPacketsToRead : 0), &mBuffers[i]);
        if (result) {
            NIMLogErr(@ "AudioQueueAllocateBuffer failed");
            XThrowIfError(result, "AudioQueueAllocateBuffer failed");
        }
	}	

	// set the volume of the queue
	result = AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0);
    if (result) {
        NIMLogErr(@ "set queue volume failed");
        XThrowIfError(result, "set queue volume failed");
    }
	
	mIsInitialized = true;
}

void AQPlayer::DisposeQueue(Boolean inDisposeFile)
{
	if (mQueue) {
		AudioQueueDispose(mQueue, true);
		mQueue = NULL;
	}
	if (inDisposeFile) {
		if (mAudioFile) {
			AudioFileClose(mAudioFile);
			mAudioFile = 0;
		}
		if (mFilePath) {
			CFRelease(mFilePath);
			mFilePath = NULL;
		}
	}
	mIsInitialized = false;
}

OSStatus AQPlayer::RestartQueue(CFStringRef filePath)
{
    DisposeQueue(true);
    
    NSError *err;
    BOOL success = [[AVAudioSession sharedInstance] setActive:YES error:&err];
    if (!success)
    {
        NIMLogErr(@
                 "Error: Set Session Active Failed Error Code :%@",
                 [err localizedDescription]);
    }
    OSStatus result;
	// if we have a file but no queue, create one now
	if (mQueue == NULL)
        CreateQueueForFile(filePath);
    UInt32 val = kAudioQueueHardwareCodecPolicy_UseSoftwareOnly;
    result = AudioQueueSetProperty(mQueue, kAudioQueueProperty_HardwareCodecPolicy, &val, sizeof(val));
    
	mIsDone = false;
	
        
    // prime the queue with some data before starting
    for (int i = 0; i < kNumberBuffers; ++i) {
        AQBufferCallback (this, mQueue, mBuffers[i]);
    }
	result =  AudioQueueStart(mQueue, NULL);
    if (result == noErr) {
        mIsRunning = true;
    }else {
        NSError *nsError = [NSError errorWithDomain:NSOSStatusErrorDomain code:result userInfo:nil];
        NIMLogErr(@
               "restart queue failed, error code:%s", [[nsError description] UTF8String]);
    }
    return result;
}
    
}
