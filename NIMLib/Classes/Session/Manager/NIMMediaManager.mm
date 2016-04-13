//
//  NIMMediaManager.m
//  NIMLib
//
//  Created by Xuhui on 15/2/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMMediaManager.h"
#import "NIMGlobalDefs.h"
#import "NIMMediaManagerProtocol.h"
#import "NIMAudioUtil.h"
#import "NIMAudioPlayer.h"
#import "NIMAudioRecorder.h"
#import "NIMAudioTrans.h"
#import "NIMDispatch.h"
using namespace NIM;

@interface NIMMediaManager () <NIMAudioPlayerDelegate, NIMAudioRecorderDelegate> {
}

@property (nonatomic, strong) NIMAudioPlayer   *audioPlayer;
@property (nonatomic, strong) NIMAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NIMAudioTrans *trans;
@property (nonatomic, assign) NSTimeInterval maxRecordDuration;
@property (nonatomic, assign) CFAbsoluteTime lastFiredTime;

@end

@implementation NIMMediaManager

- (instancetype)init
{
    self = [super init];
    if(self) {
        _recordProgressUpdateTimeInterval = 0.3;
        _trans = [[NIMAudioTrans alloc] init];
        
        [self addListeners];
        
        
    }
    return self;
}

- (void)dealloc
{
    [self removeListeners];
}

- (void)addListeners
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)removeListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onInterruption:(NSNotification *)note
{
    if(![self isRunning]) return;
    if([[note.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] isEqual:@(AVAudioSessionInterruptionTypeBegan)]) {
        if(_delegate && [_audioPlayer isPlaying] && [_audioPlayer respondsToSelector:@selector(playAudioInterruptionBegin)]) {
            nim_main_async_safe(^{
               [_delegate playAudioInterruptionBegin];
            });

        }
        if(_delegate && [_audioRecorder isRunning] && [_audioRecorder respondsToSelector:@selector(recordAudioInterruptionBegin)]) {
            nim_main_async_safe(^{
               [_delegate recordAudioInterruptionBegin];
            });
        }
    }
    if([[note.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] isEqual:@(AVAudioSessionInterruptionTypeEnded)]) {
        if(_delegate && [_audioPlayer isPlaying] && [_audioPlayer respondsToSelector:@selector(playAudioInterruptionEnd)]) {
            nim_main_async_safe(^{
              [_delegate playAudioInterruptionEnd];
            });
            
        }
        if(_delegate && [_audioRecorder isRunning] && [_audioRecorder respondsToSelector:@selector(recordAudioInterruptionEnd)]) {
            nim_main_async_safe(^{
              [_delegate recordAudioInterruptionEnd];
            });
        }
        
    }
}

- (void)onTimer:(NSTimer *)timer
{
    if ([_audioRecorder isRunning])
    {
        NSTimeInterval duration = _audioRecorder.currentTime;
        CFAbsoluteTime thisFiresd = CFAbsoluteTimeGetCurrent();
        if (thisFiresd - _lastFiredTime >= _recordProgressUpdateTimeInterval)
        {
            if(_delegate && [_delegate respondsToSelector:@selector(recordAudioProgress:)]) {
                nim_main_async_safe(^{
                    [_delegate recordAudioProgress:duration];
                });
            }
            _lastFiredTime = thisFiresd;
        }

        
        NSTimeInterval fixTimeInterval = 0.3; //目前录音的最后几帧可能没写完就把文件关掉了，所以这里做一个延时保证不会出现最大要60秒，但是显示只有59秒的情况。
        if (duration >= _maxRecordDuration + fixTimeInterval) {
            [self stopRecord];
        }
    }
    

}

- (NIMAudioPlayer *)audioPlayer
{
    if(!_audioPlayer) {
        _audioPlayer = [[NIMAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (NIMAudioRecorder *)audioRecorder
{
    if(!_audioRecorder) {
        _audioRecorder = [[NIMAudioRecorder alloc] init];
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

- (BOOL)isRunning
{
    return [_audioPlayer isPlaying] || [_audioRecorder isRunning];
}

- (void)stop
{
    if([_audioRecorder isRunning]) {
        [_audioRecorder completeRecord];
    }
    if([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
}

#pragma mark - play audio

- (BOOL)switchAudioOutputDevice:(NIMAudioOutputDevice)outputDevice {
    if(NIMAudioOutputDeviceReceiver == outputDevice) {
        return [NIMAudioUtil switchToReceiverMode];
    } else if (NIMAudioOutputDeviceSpeaker == outputDevice) {
        return [NIMAudioUtil switchToSpeakerMode];
    }
    return NO;
}

- (void)setNeedProximityMonitor:(BOOL)needProximityMonitor{
    self.audioPlayer.isNeedProximityMonitor = needProximityMonitor;
}

- (BOOL)isPlaying
{
    return [_audioPlayer isPlaying];
}

- (void)playAudio:(NSString *)filePath withDelegate:(id<NIMMediaManagerDelgate>)delegate
{
    if([self isRunning]) {
        [self stop];
    }
    _delegate = delegate;
    if(![self.audioPlayer play:filePath]) {
        if(_delegate && [_delegate respondsToSelector:@selector(playAudio:didBeganWithError:)]) {
            nim_main_sync_safe(^{
                [_delegate playAudio:filePath
                   didBeganWithError:NIMLocalError(NIMLocalErrorCodeAudioPlayErrorInitFailed)];
                _delegate = nil;
            });
        }
    }
}

- (void)stopPlay {
    if([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
}

#pragma mark - record audio

- (BOOL)isRecording {
    return [_audioRecorder isRunning];
}

- (void)record:(NIMAudioType)type
      duration:(NSTimeInterval)duration
      delegate:(id<NIMMediaManagerDelgate>)delegate
{
    if([self isRunning]) {
        [self stop];
    }
    __weak typeof(self) weakSelf = self;
    weakSelf.delegate = delegate;
    [NIMAudioUtil hasRecordGranted:^(BOOL granted)
    {
        nim_main_async_safe(^{
            if(granted)
            {
                if([weakSelf isRunning])
                {
                    [weakSelf stop];
                }
                AudioType recordType = [self recordAudioTypeBy:type];
                if([weakSelf.audioRecorder prepareToRecord] &&
                   [weakSelf.audioRecorder record:recordType])
                {
                    _maxRecordDuration = duration;
                }
                else
                {
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(recordAudio:didBeganWithError:)])
                    {
                        [weakSelf.delegate recordAudio:nil
                                     didBeganWithError:NIMLocalError(NIMLocalErrorCodeAudioRecordErrorInitFailed)];
                    }
                    weakSelf.delegate = nil;
                }
            }
            else
            {
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(recordAudio:didBeganWithError:)])
                {
                    [weakSelf.delegate recordAudio:nil
                                 didBeganWithError:NIMLocalError(NIMLocalErrorCodeAudioRecordErrorNoPermission)];
                }
                weakSelf.delegate = nil;
            }
        });
    }];
}

- (void)recordAudioForDuration:(NSTimeInterval)duration
                  withDelegate:(id<NIMMediaManagerDelgate>)delegate
{
    [self record:NIMAudioTypeAAC
        duration:duration
        delegate:delegate];
    
}

- (void)stopRecord {
    if([_audioRecorder isRunning]) {
        [_audioRecorder completeRecord];
    }
}

- (void)cancelRecord {
    if([_audioRecorder isRunning]) {
        [_audioRecorder cancelRecord];
    }
}

- (NIM::AudioType)recordAudioTypeBy:(NIMAudioType)type
{
    AudioType result = kAudioTypeAAC;
    if (type == NIMAudioTypeAMR)
    {
        result = kAudioTypeAMR;
    }
    return result;
}

#pragma mark - Audio to text
- (void)transAudioToText:(NIMAudioToTextOption *)option
                  result:(NIMAudioToTextBlock)block
{
    [_trans trans:option
       completion:block];
}

- (void)setDeactivateAudioSessionAfterComplete:(BOOL)deactivate
{
    [self.audioPlayer setAutoDeactivateAudioSession:deactivate];
    [self.audioRecorder setAutoDeactivateAudioSession:deactivate];
}

#pragma mark - NIMAudioPlayerDelegate

- (void)audioPlayerBegin:(NSString *)filepath
{
    if(_delegate && [_delegate respondsToSelector:@selector(playAudio:didBeganWithError:)]) {
        nim_main_async_safe(^{
          [_delegate playAudio:filepath didBeganWithError:nil];
        });
    }
}

- (void)audioPlayerEnd:(NSString *)filepath error:(NSError *)error
{
    if(_delegate && [_delegate respondsToSelector:@selector(playAudio:didCompletedWithError:)]) {
        nim_main_sync_safe(^{ //同步，防止播放完的同时又起了一个播放/录音任务，导致delegate为空
            [_delegate playAudio:filepath didCompletedWithError:error];
            _delegate = nil;
        });
        
    }
}

- (void)audioPlayerCancelled:(NSString *)filepath
{
    [_timer invalidate];
    _timer = nil;
    if(_delegate && [_delegate respondsToSelector:@selector(playAudio:didCompletedWithError:)]) {
        nim_main_sync_safe(^{//同步，防止播放取消的同时又起了一个播放/录音任务，导致delegate为空
            [_delegate playAudio:filepath didCompletedWithError:nil];
            _delegate = nil;
        });
    }
}

#pragma mark - NIMAudioRecorderDelegate

- (void)audioDidStarted: (BOOL)isSuccessed filepath:(NSString *)filepath
{
    NSError *error = nil;
    if(isSuccessed){
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.033
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
        _lastFiredTime = CFAbsoluteTimeGetCurrent();
        
    } else {
        error = NIMLocalError(NIMLocalErrorCodeAudioRecordErrorInitFailed);
        filepath = nil;
    }
    if(_delegate && [_delegate respondsToSelector:@selector(recordAudio:didBeganWithError:)]) {
        nim_main_async_safe(^{
            [_delegate recordAudio:filepath didBeganWithError:error];
        });
    }
}

- (void)audioDidFinished: (NSString *)filepath url: (NSURL *)url successfully: (BOOL)flag
{
    [_timer invalidate];
    _timer = nil;
    
    if(flag) {
        NSError *error = nil;
        if(filepath == nil) {
            error = NIMLocalError(NIMLocalErrorCodeAudioRecordErrorRecordFailed);
        }
        if(_delegate && [_delegate respondsToSelector:@selector(recordAudio:didCompletedWithError:)]) {
            nim_main_sync_safe(^{ //同步，防止录音完的同时又起了一个播放/录音任务，导致delegate为空
                [_delegate recordAudio:filepath didCompletedWithError:error];
                _delegate = nil;
            });
        }
    } else {
        if(_delegate && [_delegate respondsToSelector:@selector(recordAudioDidCancelled)]) {
            nim_main_sync_safe(^{//同步，防止取消完的同时又起了一个播放/录音任务，导致delegate为空
                [_delegate recordAudioDidCancelled];
                _delegate = nil;
            });
        }
    }
}

- (float)recordPeakPower {
    return [_audioRecorder isRunning] ? _audioRecorder.peakPower : 0.f;
}

- (float)recordAveragePower {
    return [_audioRecorder isRunning] ? _audioRecorder.averagePower : 0.f;
}

@end
