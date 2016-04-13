//
//  NIMAudioPlayerEx.m
//  NIM
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "NIMAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "NIMGlobalDefs.h"
#import "AQPlayer.h"
#import "NIMAudioUtil.h"
#import "NIMAMRDecoder.h"

using namespace NIM;


@interface NIMAudioPlayer () {
    AQPlayer        *_aqPlayer;
    BOOL            _isCanceled;
}
@property (nonatomic,strong)    NSString    *playFilepath;
@end

@implementation NIMAudioPlayer


- (id)init
{
    if (self = [super init]) {
        [self addListenEvents];
        _isCanceled = false;
        _isNeedProximityMonitor = YES;
        _autoDeactivateAudioSession = YES;
        _aqPlayer = new AQPlayer();
    }
    
    return self;
}

- (void)dealloc
{
    [self stop];
    [self removeListenEvents];
    _delegate = nil;
    delete _aqPlayer;
}

#pragma mark - 私有实现
- (void)addListenEvents
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlayerError:)
                                                 name:NIMNotificationAQPlayerError
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlayerEnd:)
                                                 name:NIMNotificationAQPlayerEnd
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlayerInterruptBegin:)
                                                 name:kNIMNotificationAQPlayerInterrBegin
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlayerInterruptEnd:)
                                                 name:kNIMNotificationAQPlayerInterrEnd
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onAudioRouteChange:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: nil];
    
}

- (void)removeListenEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cancelPreviousPlayer
{
    if (_aqPlayer) {
        if (_aqPlayer->IsRunning()) {
            NIMLogApp(@ "try to stop queue");
            _isCanceled = true;
            _aqPlayer->StopQueue();
            [self performDelegateSelector:@selector(audioPlayerCancelled:)];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        _aqPlayer->DisposeQueue(true);
    }
}

- (void)resetAudioSessionAfterPlaying
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    if (_autoDeactivateAudioSession) {
        [[AVAudioSession sharedInstance] setActive:NO
                                       withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
}

- (void)resetAudioSessionBeforePlaying{
    if (_isNeedProximityMonitor) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
    AVAudioSessionCategoryOptions currentOptions = AVAudioSession.sharedInstance.categoryOptions;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:currentOptions error:nil];
}

#pragma mark - 对外接口
- (BOOL)play:(NSString *)filepath
{
    [self cancelPreviousPlayer];
    self.filepath = filepath;   //这里仍旧使用原文件路径
    self.playFilepath = filepath;
    
    //如果是amr文件，进行一次转码
    if ([NIMAMRDecoder isFileAmr:filepath])
    {
        self.playFilepath = [NIMAMRDecoder decode:filepath];
        NIMLogApp(@"decode from %@ to %@",_filepath,_playFilepath);
    }

    NIMLogApp(@"try to play filepath:%@",_playFilepath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:_playFilepath]) {
        if (_aqPlayer) {
            [self resetAudioSessionBeforePlaying];
            [NIMAudioUtil enableBluetooth];
            OSStatus result =  _aqPlayer->StartQueue((__bridge CFStringRef)_playFilepath);
            if (result) {
                NSError *nsError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                       code:result
                                                   userInfo:nil];
                NIMLogErr(@"applayer start queue failed, filepath:%@, errorcode:%@",
                       _playFilepath,[nsError description]);
                
                return false;
            }
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [self performDelegateSelector:@selector(audioPlayerBegin:)];
            
            return true;
        }
        else {
            NIMLogErr(@"Error: audio player not inited.");
        }
    }
    else {
        NIMLogErr(@"Error: audio file not exist %@.", _playFilepath);
    }
    
    return false;
}

- (void)stop
{
    [self cancelPreviousPlayer];
    [self resetAudioSessionAfterPlaying];
    [self performDelegateSelector:@selector(afterAVAudioSessionSetActive)];
    
}

#pragma mark - 事件回调
- (void)onSensorStateChange: (NSNotification *)aNotification
{
    if (!_aqPlayer) {
        return;
    }
    
    //Bug #24844，同时按照策划要求，蓝牙在用时始终从蓝牙输出，且不关闭传感器
    if ([NIMAudioUtil isUsingBluetooth]) {
        return;
    }

    if ([self isPlaying]) {
            _aqPlayer->PauseQueue();
    }
    //规则： 听筒播放情况下，不管是远距离，还是近距离，都是听筒播放， 扬声器模式播放的情况下，近距离时，切成听筒播放，远距离时，切回扬声器播放
    
    if ([[UIDevice currentDevice] proximityState]) //近距离的时候，一定是听筒播放
    {
        [NIMAudioUtil switchToReceiverMode];
    }else { //远距离，切回扬声器播放
        [NIMAudioUtil switchToSpeakerMode];
    }
    _aqPlayer->ResumeQueue((__bridge CFStringRef)_playFilepath);
    
   
}

- (void)onPlayerError:(NSNotification *)notification
{
    [self resetAudioSessionAfterPlaying];
    if([_delegate respondsToSelector:@selector(audioPlayerEnd:error:)]) {
        [_delegate audioPlayerEnd:_filepath error:NIMLocalError(NIMLocalErrorCodeInvalidMedia)];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)onPlayerInterruptBegin:(NSNotification *)notification
{
    [self performDelegateSelector:@selector(audioPlayerBeginInterruption:)];
}

- (void)onPlayerInterruptEnd:(NSNotification *)notification
{
    [self performDelegateSelector:@selector(audioPlayerEndInterruption:)];
}

- (void)onPlayerEnd:(NSNotification *)notification
{
    [self resetAudioSessionAfterPlaying];
    // 取消操作以后，不再回调上层end
    if (_isCanceled) {
        _isCanceled = false;
        return;
    }
    if([_delegate respondsToSelector:@selector(audioPlayerEnd:error:)]) {
        [_delegate audioPlayerEnd:_filepath error:nil];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)onAudioRouteChange:(NSNotification*)notification{
    
    if (![self isPlaying]) {
        return;
    }
    
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            if (![[UIDevice currentDevice] proximityState]) {
                [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            }
            break;
        default:
            break;
    }
}

- (void)performDelegateSelector:(SEL)selector
{
    if (_delegate && [_delegate respondsToSelector:selector]) {
        NIMSuppressPerformSelectorLeakWarning([_delegate performSelector:selector withObject:_filepath]);
        
    }
}

- (BOOL)isPlaying
{
    return _aqPlayer && _aqPlayer->IsRunning();
}

- (float)averagePower {
    return [self isPlaying] ? _aqPlayer->GetAveragePowerDB() : 0.f;
}

- (float)peakPower {
    return [self isPlaying] ? _aqPlayer->GetPeakPowerDB() : 0.f;
}

- (NSTimeInterval)currentTime {
    return [self isPlaying] ? _aqPlayer->GetCurrentTime() : 0.;
}

@end
