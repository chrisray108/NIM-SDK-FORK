/*

    File: AQRecorder.mm
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

#include "AQRecorder.h"
#include "AACPlusEncoder.h"
#include "AMREncoder.h"
#import <AVFoundation/AVAudioSession.h>

namespace NIM {

#define FRAME_COUNT_PER_PACKET 3

// ____________________________________________________________________________________
// Determine the size, in bytes, of a buffer necessary to represent the supplied number
// of seconds of audio data.
int AQRecorder::ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds)
{
	int packets, frames, bytes = 0;
	try {
		frames = (int)ceil(seconds * format->mSampleRate);
		
		if (format->mBytesPerFrame > 0)
			bytes = frames * format->mBytesPerFrame;
		else {
			UInt32 maxPacketSize;
			if (format->mBytesPerPacket > 0)
				maxPacketSize = format->mBytesPerPacket;	// constant packet size
			else {
				UInt32 propertySize = sizeof(maxPacketSize);
				XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
												 &propertySize), "couldn't get queue's maximum output packet size");
			}
			if (format->mFramesPerPacket > 0)
				packets = frames / format->mFramesPerPacket;
			else
				packets = frames;	// worst-case scenario: 1 frame in a packet
			if (packets == 0)		// sanity check
				packets = 1;
			bytes = packets * maxPacketSize;
		}
	} catch (CAXException e)
    {
		char buf[256] = {0};
        e.FormatError(buf);
        NIMLogErr(@"Error: Write Buffer: %s (%s)",e.mOperation,buf);
		return 0;
	}	
	return bytes;
}

// ____________________________________________________________________________________
// AudioQueue callback function, called when an input buffers has been filled.
void AQRecorder::MyInputBufferHandler(	void *								inUserData,
										AudioQueueRef						inAQ,
										AudioQueueBufferRef					inBuffer,
										const AudioTimeStamp *				inStartTime,
										UInt32								inNumPackets,
										const AudioStreamPacketDescription*	inPacketDesc)
{
	AQRecorder *aqr = (AQRecorder *)inUserData;
	try
    {
		if (inNumPackets > 0)
        {
            SpeechEnhancer<NoiseEstimater_MMSE, SpectrumRestorer_MMSE> *enhancer =
            aqr->GetSpeechEnhancer();
            if (!enhancer)
            {
                NIMLogErr(@"get enhancer error");
                return;
            }
            int32_t size = inBuffer->mAudioDataByteSize / 2;
            int16_t *short_buffer = (int16_t *)inBuffer->mAudioData;
            float *float_buffer = new float[size];
            for (int i = 0; i < size; i++)
            {
                float_buffer[i] = short_buffer[i] * 1.0 / INT16_MAX;
            }
            std::vector<float> data = aqr->mSpeechEnhancer->apply(float_buffer,size);
            delete []float_buffer;
            if (data.size())
            {
                int16_t *write_buffer = new int16_t[data.size()];
                for (size_t i = 0; i < data.size(); i++)
                {
                    write_buffer[i] = (int16_t)(data[i] * INT16_MAX);
                }
                
                // write packets to file
                AudioEncoder *encoder = aqr->GetEncoder();
                std::vector<uint8_t> vt = encoder->Encode(write_buffer, (int)(data.size() * sizeof(int16_t)));
                aqr->WriteToFile(vt);

                delete []write_buffer;
            }
            else
            {
                
            }
			aqr->mRecordPacket += inNumPackets;
		}
		
		// if we're not stopping, re-enqueue the buffe so that it gets filled again
		if (aqr->IsRunning())
			XThrowIfError(AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL), "AudioQueueEnqueueBuffer failed");
	}
    catch (CAXException e)
    {
        char buf[256] = {0};
        e.FormatError(buf);
        NIMLogErr(@"Error: Write Buffer: %s (%s)",e.mOperation,buf);
	}
}



AQRecorder::AQRecorder()
{
	mIsRunning = false;
	mRecordPacket = 0;
    mSpeechEnhancer = 0;
    mEncoder = 0;
    mFilepath = 0;
    mFile = 0;
    mTotalWriteLength = 0;
    autoDeactivateAudioSession = YES;
}

AQRecorder::~AQRecorder()
{
	AudioQueueDispose(mQueue, TRUE);
    delete mSpeechEnhancer;
    delete mEncoder;
    if(mFile)
    {
        fclose(mFile);
    }
}


BOOL AQRecorder::SetupAudioFormat(UInt32 inFormatID,AudioType type)
{
	memset(&mRecordFormat, 0, sizeof(mRecordFormat));
    mRecordFormat.mChannelsPerFrame = 1;
    mRecordFormat.mSampleRate = type == kAudioTypeAMR ? 8000 : GetAACSampleRate();
    
    if (mSpeechEnhancer)
    {
        delete mSpeechEnhancer;
    }
    int sampleRate = (int)mRecordFormat.mSampleRate;
    mSpeechEnhancer  = new SpeechEnhancer<NoiseEstimater_MMSE, SpectrumRestorer_MMSE>(sampleRate);
			
	mRecordFormat.mFormatID = inFormatID;
	if (inFormatID == kAudioFormatLinearPCM)
	{
		// if we want pcm, default to signed 16-bit little-endian
		mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
		mRecordFormat.mBitsPerChannel = 16;
		mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
		mRecordFormat.mFramesPerPacket = 1;
	}
    if (mEncoder)
    {
        delete mEncoder;
        mEncoder = 0;
    }
    switch (type)
    {
        case kAudioTypeAMR:
            mEncoder = new AMREncoder();
            break;
        case kAudioTypeAAC:
            mEncoder = new AACPlusEncoder();
            break;
        default:
            assert(0);
            break;
    }
    if (!mEncoder->Init((int)mRecordFormat.mSampleRate,
                        mRecordFormat.mChannelsPerFrame,
                        0.625 * 44100)) //3g网络建议再打对折，2g建议12000，
    {
        return NO;
    }
    return YES;
    
}

Float64 AQRecorder::GetAACSampleRate()
{
    return 44100;
}

BOOL AQRecorder::StartRecord(NSString *inRecordFilepath, AudioType type)
{
    BOOL success = YES;
	int i, bufferByteSize;
	UInt32 size;
	
	try {
        
        NSError *err;
        BOOL success = [[AVAudioSession sharedInstance] setActive:YES error:&err];
        if (!success)
        {
            NIMLogErr(@"Error: Set Session Active Failed Error Code :%@",
                     [err localizedDescription]);
        }

		// specify the recording format
		if(!SetupAudioFormat(kAudioFormatLinearPCM,type))
        {
            NIMLogErr(@"Error: Setup Audio Format Error");
            return NO;
        }
		
		// create the queue
		XThrowIfError(AudioQueueNewInput(
									  &mRecordFormat,
									  MyInputBufferHandler,
									  this /* userData */,
									  NULL /* run loop */, NULL /* run loop mode */,
									  0 /* flags */, &mQueue), "AudioQueueNewInput failed");
		
		// get the record format back from the queue's audio converter --
		// the file may require a more specific stream description than was necessary to create the encoder.
		mRecordPacket = 0;

		size = sizeof(mRecordFormat);
		XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_StreamDescription,	
										 &mRecordFormat, &size), "couldn't get queue's format");
        
        if (mFilepath != inRecordFilepath)
        {
            mFilepath = inRecordFilepath;
        }
        
        if (!OpenFileForRecord(type))
        {
            NIMLogErr(@"Error: Begin Record Open File Error");
            success = NO;
        }
		
		// allocate and enqueue buffers
        const float kBufferDurationSeconds = 0.5f;
		bufferByteSize = ComputeRecordBufferSize(&mRecordFormat, kBufferDurationSeconds);	// enough bytes for half a second
		for (i = 0; i < kNumberRecordBuffers; ++i) {
			XThrowIfError(AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]),
					   "AudioQueueAllocateBuffer failed");
			XThrowIfError(AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL),
					   "AudioQueueEnqueueBuffer failed");
		}
		// start the queue
		mIsRunning = true;
		XThrowIfError(AudioQueueStart(mQueue, NULL), "AudioQueueStart failed");
        
        UInt32 d = 1;
        AudioQueueSetProperty(mQueue, kAudioQueueProperty_EnableLevelMetering, &d, sizeof(UInt32));
	}
	catch (CAXException e)
    {
        char buf[256] = {0};
        e.FormatError(buf);
        NIMLogErr(@"Error: Begin Record: %s (%s)",e.mOperation,buf);
        success = NO;
	}
	catch (...)
    {
		NIMLogErr(@"Error: Unknown Error Happened While Record");
        success = NO;
	}
    return success;
}


void AQRecorder::WriteToFile(const std::vector<uint8_t> &input_data)
{
    if (mFile)
    {
        int left_length = (int)input_data.size();
        while (left_length > 0)
        {
            int input = (int)fwrite(&input_data[input_data.size() - left_length], sizeof(uint8_t), left_length , mFile);
            if (input > 0)
            {
                left_length -= input;
                mTotalWriteLength += input;
            }
            else
            {
                NIMLogErr(@"Error: Unknown Error Happened While Write Data to File");
                break;
            }
        }
        
        if (mTotalWriteLength > 1024 * 100) //每写入100KB就刷新一次
        {
            fflush(mFile);
            mTotalWriteLength = 0;
        }        
    }
}

BOOL AQRecorder::OpenFileForRecord(AudioType type)
{
    if (mFile)
    {
        fclose(mFile);
        mFile = 0;
    }
    mTotalWriteLength = 0;
    const char *filepath = [mFilepath UTF8String];
    if (filepath == 0)
    {
        return NO;
    }
    if (access(filepath, F_OK) == 0)
    {
        unlink(filepath);
    }
    mFile = fopen(filepath, "ab+");
    if (mFile)
    {
        if (type == kAudioTypeAMR)
        {
            std::string fileHeader = "#!AMR\n";
            fwrite(fileHeader.c_str(), 1, fileHeader.size(), mFile);
        }
    }
    return mFile != 0;
}
    
float   AQRecorder::GetPeakPowerDB()
{
    if (!mIsRunning || mQueue == 0)
    {
        return 0;
    }
    float value = 0;
    UInt32 dataSz = sizeof(AudioQueueLevelMeterState) * mRecordFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *state = (AudioQueueLevelMeterState *)malloc(dataSz);
    OSStatus status = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeterDB, state,
                                            &dataSz);
    if (status == noErr)
    {
        for (int i = 0; i < mRecordFormat.mChannelsPerFrame; i++) {
            value += state[i].mPeakPower;
        }
    }
    free(state);
    return value;
}

float   AQRecorder::GetAveragePowerDB()
{
    if (!mIsRunning || mQueue == 0)
    {
        return 0;
    }
    float value = 0;
    UInt32 dataSz = sizeof(AudioQueueLevelMeterState) * mRecordFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *state = (AudioQueueLevelMeterState *)malloc(dataSz);
    OSStatus status = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeterDB, state,
                                            &dataSz);
    if (status == noErr)
    {
        for (int i = 0; i < mRecordFormat.mChannelsPerFrame; i++) {
            value += state[i].mAveragePower;
        }
    }
    free(state);
    return value;
}
    
double   AQRecorder::GetCurrentTime()
{
    if (!mIsRunning || mQueue == 0) {
        return 0;
    }
    AudioTimeStamp timeStamp;
    AudioQueueGetCurrentTime(mQueue, NULL, &timeStamp, NULL);
    return timeStamp.mSampleTime / mRecordFormat.mSampleRate;
}

BOOL AQRecorder::StopRecord()
{
    if (!mIsRunning)
    {
        return NO;
    }
    try
    {
        // end recording
        BOOL success = NO;
        mIsRunning = false;
        XThrowIfError(AudioQueueStop(mQueue, true), "AudioQueueStop failed");
        // a codec may update its cookie at the end of an encoding session, so reapply it to the file now
        AudioQueueDispose(mQueue, true);
        
        if(mFile)
        {
            success = (fclose(mFile) == 0);
            mFile = 0;
            if(!success) {
                NIMLogErr(@"Error: close file failed, Error code :%zd", errno);
                return NO;
            }
        }
        
        if (autoDeactivateAudioSession) {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            NSError *err;
            success = [session setActive:NO
                             withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                   error:&err];
            if (!success)
            {
                NIMLogErr(@"Error: Set Session Active Failed, Error Code :%@",
                          [err localizedDescription]);
            }
        }
        
        return YES;

    }
    catch (CAXException e)
    {
        char buf[256] = {0};
        e.FormatError(buf);
        NIMLogErr(@"Error: Finish Record: %s (%s)",e.mOperation,buf);
        return NO;
	}
	catch (...)
    {
		NIMLogErr(@"Error: Unknown Error Happened While Finish Record");
        return NO;
	}
}
    
}
