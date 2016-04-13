//
//  NVSSessionManager.h
//  VideoChatDemo
//
//  Created by user on 13-11-21.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NVSDefine.h"
#import "NVSDelegate.h"

@interface NVSSessionParam : NSObject

@property (nonatomic, assign) NVSClientType myClientType;   //本端客户端类型
@property (nonatomic, assign) NVSClientType peerClientType; //对端客户端类型
@property (nonatomic, strong) NSString  *clientName;        //描述名, 也用于网络层日志文件名

@property (nonatomic, assign) uint64_t  clientID;     //节点id
@property (nonatomic, assign) uint64_t  channelID;    //频道id
@property (nonatomic, assign) NVSSessionMode  mode;   //音视频模式


@property (nonatomic, assign) NVSTokenEncryptType encryptType;
@property (nonatomic, copy  ) NSString  *encryptToken;

@property (nonatomic, copy  ) NSString  *turnAddr;    //turn服务器地址
@property (nonatomic, copy  ) NSString  *stunAddr1;   //stun服务器地址1
@property (nonatomic, copy  ) NSString  *stunAddr2;   //stun服务器地址2
@property (nonatomic, copy  ) NSString  *proxyAddr;   //代理服务器地址

@property (nonatomic, assign) uint16_t  logLevel;     //log输出等级:建议发布版传6，其他传7
@property (nonatomic, copy  ) NSString  *logPath;     //log输出目录，不要带文件名

@property (nonatomic, assign) BOOL  disableP2P;       //禁用P2P
@property (nonatomic, assign) BOOL  useBackCapture;   //使用后置摄像头

@property (nonatomic, assign) BOOL serverRecordAudio; //服务器录制语音
@property (nonatomic, assign) BOOL serverRecordVideo; //服务器录制视频

@property (nonatomic, copy  ) NSString *callConfig;   //针对一通电话的特殊配置

@property (nonatomic, strong) NSArray *turnAddrArrays; //分组了的turn地址列表
@property (nonatomic, strong) NSArray *proxyAddrs;     //proxy地址列表

@property (nonatomic, assign) BOOL disableDTunnel;

@property (nonatomic, assign) NVSVideoQuality preferredVideoQuality; //期望的视频质量(清晰度)

@property (nonatomic, assign) BOOL noCropping;

@end

@interface NVSSessionReport : NSObject<NSCopying>

@property (nonatomic, assign) uint64_t  channelID;
@property (nonatomic, copy)   NSString  *errorDescription;
@property (nonatomic, assign) uint64_t  totalTxBytes;
@property (nonatomic, assign) uint64_t  totalRxBytes;

@end

@interface NVSSessionRecordInfo : NSObject
@property (nonatomic, assign) uint64_t  channelID;
@property (nonatomic, copy)   NSString  *recordAddr;
@property (nonatomic, copy)   NSString  *recordFile;

@end

@interface NVSSessionManager : NSObject

@property(nonatomic,assign) uint64_t channelID;
@property(nonatomic,assign) NVSSessionMode sessionMode;

@property(nonatomic, weak) id<NVSSessionDelegate> sessionDelegate;

// 初始化接口
//////////////////////////////////////
// 需要提供上层的delegate，用于本地视频回放
//////////////////////////////////////
- (id)initWithLocalPlayerDelegate:(id<NVSVideoPlayerDelegate>)delegate;

// 开启聊天
- (void)startChat:(NVSSessionParam *)sessionParam;

// 停止聊天
- (void)stopChat;

// 静音设置
/////////////////////////////////////////////
// 0 (default) = muting off. 1 = mute output.
/////////////////////////////////////////////
- (BOOL)setMute:(int)flag;

// 扬声器开关
/////////////////////////////////////////////
// 1 (default) = speaker on. 0 = speaker off
////////////////////////////////////////////
- (BOOL)setSpeake:(int)flag;

// 语音视频模式切换
////////////////////////////////////////////
// NVSSessionModeAudio         = 1,     //语音
// NVSSessionModeVideo         = 2,     //视频
////////////////////////////////////////////
- (void)switchChatMode:(NSInteger)mode keepSettings:(BOOL)keepSettings;

// 摄像头切换
//////////////////////////////////////////
//	AVCaptureDevicePositionBack       = 1
//  AVCaptureDevicePositionFront      = 2
/////////////////////////////////////////
- (void)switchVideoDevice:(int)type;

/**
 *  设置关闭摄像头, 只支持视频模式
 *
 *  @param closed 是否关闭摄像头
 *
 *  @return 操作结果
 */
- (BOOL)setCamera:(BOOL)closed;

// 设置log日志输出代理
- (void)setLogDelegate:(id<NVSLogDelegate>)delegate;


//发送app透传数据
- (void)sendAppData:(NSData *)data to:(uint64_t)client;

//获取录制数据信息
- (NVSSessionRecordInfo *)recordInfo;

+ (UIImage *)i420FrameToImage:(NVSI420Frame *)frame;

+ (uint32_t)netVersion;

+ (uint32_t)nvsVersion;

/**
 *  可以录制
 *
 *  @return 是否可以录制
 */
- (BOOL)readyToRecord;

/**
 *  开始录制,只能在用户加入以后再开始
 *
 *  @param file           文件名, 不传的话会用频道号生成默认文件
 *  @param videoBitrate   视频码率, 可以不传
 *  @param delegate 回调
 *
 *  @return 开始录制结果
 */
- (NVSRecordingError)startRecording:(NSURL *)file
                       videoBitrate:(UInt32)videoBitrate
                           delegate:(id<NVSRecordingDelegate>)delegate;

/**
 *  结束录制
 *
 *  @return 开始录制结果
 */
- (NVSRecordingError)stopRecording;

@end
