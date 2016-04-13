//
//  NIMAudioRecorder.m
//  NIM
//
//  Created by amao on 13-1-23.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "NIMAudioRecorder.h"
#import "NIMAudioUtil.h"
#import "NIMUtil.h"
#import "NIMPathManager.h"
using namespace NIM;

@interface NIMAudioRecorder ()
{
    BOOL                _cancelled;
    NSInteger           _totalSeconds;
    NSString            *_filename;
    NSString            *_filepath;
    NIM::AQRecorder     *_recorder;
}
@end


@implementation NIMAudioRecorder

- (id)init
{
    if (self = [super init])
    {
        _recorder = new AQRecorder();
    }
    return self;
}

- (void)dealloc
{
    delete _recorder;
}


- (BOOL)isRunning {
    return _recorder->IsRunning();
}

- (float)averagePower {
    return [self isRunning] ? _recorder->GetAveragePowerDB() : 0.f;
}

- (float)peakPower {
    return [self isRunning] ? _recorder->GetPeakPowerDB() : 0.f;
}

- (NSTimeInterval)currentTime {
    return [self isRunning] ? _recorder->GetCurrentTime() : 0;
}

- (BOOL)prepareToRecord
{
    if([self isRunning]) {
        NIMLogErr(@"Stop Recording First!");
        return NO;
    }
    BOOL active = [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (!active)
    {
        NIMLogErr(@"Error Set Session Active Failed Before Recording");
    }
    BOOL result = [NIMAudioUtil switchToReceiverMode];
    if (!result)
    {
        NIMLogErr(@"Error Set Session Category to AVAudioSessionCategoryPlayAndRecord \
               Failed Before Recording");
    }
    return YES;
    
}

- (BOOL)record:(AudioType)type
{   
    BOOL success = NO;
    [self initRecordOutputParam:type];
    
    if (_recorder->IsRunning())
    {
        _recorder->StopRecord();
    }
    else
    {
        success = _recorder->StartRecord(_filepath, type);
        _cancelled = NO;
    }
    
    if (success) {
        if (_delegate && [_delegate respondsToSelector:@selector(audioDidStarted:filepath:)])
        {
            [_delegate audioDidStarted:success filepath:_filepath];
        }
    }
    return success;
}

- (void)cancelRecord
{
    _cancelled = YES;
    [self stopRecord];
}

- (void)completeRecord
{
    _cancelled = NO;
    [self stopRecord];
}


- (void)stopRecord
{
    BOOL stop = _recorder->StopRecord();
    if (stop)
    {
        if (_cancelled)
        {
            if (_delegate && [_delegate respondsToSelector:@selector(audioDidFinished:url:successfully:)])
            {
                [_delegate audioDidFinished:_filepath url:nil successfully:NO];
            }
        }
        else
        {
            if (_delegate && [_delegate respondsToSelector:@selector(audioDidFinished:url:successfully:)])
            {
                [_delegate audioDidFinished:_filepath url:nil successfully:YES];
            }
        }
    }
    else
    {
        if (_delegate && [_delegate respondsToSelector:@selector(audioDidFinished:url:successfully:)])
        {
            [_delegate audioDidFinished:nil url:nil successfully:NO];
        }
    }
    //录音结束，切回扬声器
    [NIMAudioUtil switchToSpeakerMode];
}

- (void)setAutoDeactivateAudioSession:(BOOL)deactivate
{
    if (_recorder) {
        _recorder->autoDeactivateAudioSession = deactivate;
    }
}

#pragma mark - 辅助方法
- (void)initRecordOutputParam:(AudioType)type
{
    _cancelled = NO;
    NSString *ext = type == kAudioTypeAMR ? @"amr" : @"aac";
    _filename = [NIMUtil genFilenameWithExt:ext];
    _filepath = [[[NIMPathManager sharedManager] sdkNIMResourcePath] stringByAppendingPathComponent:_filename];
}




@end
