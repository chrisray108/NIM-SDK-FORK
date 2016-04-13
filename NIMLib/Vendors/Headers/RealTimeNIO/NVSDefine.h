//
//  NVSDefine.h
//  VideoChatDemo
//
//  Created by user on 13-12-4.
//
//

#ifndef VideoChatDemo_VideoChatDefine_h
#define VideoChatDemo_VideoChatDefine_h

#define NVSAudioPacketHeadSize 4
#define NVSVideoPacketHeadSize 20
#define NVSVideoPacketHeadSizeNew 24

// 暂时先对上层开发这两种状态，加入、离开
typedef enum {
    NVSVideoChatSessionStatusJoined           = 0,
    NVSVideoChatSessionStatusLeaved           = 1,
    NVSVideoChatSessionStatusDisconnected     = 2,
    NVSVideoChatSessionStatusPeerVersionLow   = 3,
    NVSVideoChatSessionStatusSelfVersionLow   = 4,
}NVSVideoChatSessionStatus;

typedef enum {
    NVSVideoChatSessionNetStatVeryGood    = 0,
    NVSVideoChatSessionNetStatGood        = 1,
    NVSVideoChatSessionNetStatBad         = 2,
    NVSVideoChatSessionNetStatVeryBad     = 3,
}NVSVideoChatSessionNetStat;

enum
{
    NVSTagSpeekerOff = 0,
    NVSTagSpeekerOn,
};

typedef enum {
    NVSP2PMsgCodeConnectSuccess           = 401,
    NVSP2PMsgCodeConnectFail              = 402,
    NVSP2PMsgCodeNatTypeFullcone          = 403,
    NVSP2PMsgCodeNatTypePortrestricted    = 404,
    NVSP2PMsgCodeNatTypeSymmetric         = 405,
    NVSP2PMsgCodeNatTypeUnknow            = 406,
}NVSP2PMsgCode;

typedef enum {
    NVSLoginErrorTimeout          = 101,
    NVSLoginErrorSuccess          = 200,
    NVSLoginErrorInvalidParam     = 400,
    NVSLoginErrorKeyInvalid       = 401,
    NVSLoginErrorInvalidRequst    = 417,
    NVSLoginErrorServerUnknown    = 500,
}NVSLoginErrorCode;

typedef enum {
    NVSRecordingErrorNoError       = 0,
    NVSRecordingErrorNotReady      = 1,
    NVSRecordingErrorNotRecording  = 2,
    
    NVSRecordingErrorCreateFile    = 3,
    NVSRecordingErrorInitVideo     = 4,
    NVSRecordingErrorInitAudio     = 5,
    
    NVSRecordingErrorStartWriting  = 6,
    
    NVSRecordingErrorWritingInterrupted = 7,
    
    NVSRecordingErrorWillStopForLackSpace = 8,
    
    NVSRecordingErrorInvalidFilePath = 9,

}NVSRecordingError;

typedef enum {
    NVSEncryptTypeNone    = 0,
    NVSEncryptTypeAES     = 1,
    NVSEncryptTypeDES     = 2,
}NVSTokenEncryptType;

typedef enum {
    NVSVideoCodecTypeH264 = 5,
}NVSVideoCodecType;

typedef enum {
    NVSAudioCodecTypeNo   = 0,
    NVSAudioCodecTypeg711 = 2,
    NVSAudioCodecTypeOpus = 4,
    NVSAudioCodecTypeiLBC = 5,
    NVSAudioCodecTypeisac = 6,
}NVSAudioCodecType;

typedef enum {
    NVSAudioFrameSizeUnspec  = 0,
    NVSAudioFrameSize20ms    = 1,
    NVSAudioFrameSize30ms    = 2,
    NVSAudioFrameSize60ms    = 3,
    
    NVSAudioFrameSize40ms    = 10,
    NVSAudioFrameSize80ms    = 11,
    NVSAudioFrameSize100ms   = 12,
    NVSAudioFrameSize120ms   = 13,
}NVSAudioFrameSize;

typedef enum {
    NVSAudioFrameTypeVAD      = 1,
    NVSAudioFrameTypeNormal   = 2,
    NVSAudioFrameTypeDTX      = 3,
}NVSAudioFrameType;

typedef enum {
    NVSAudioHeadMajorVersion0 = 0,
    NVSAudioHeadMajorVersion1 = 1,
    NVSAudioHeadMajorVersion2 = 2,
    NVSAudioHeadMajorVersion3 = 3,
}NVSAudioHeadMajorVersion;

typedef enum {
    NVSAudioHeadMinorVersion0 = 0,
    NVSAudioHeadMinorVersion1 = 1,
    NVSAudioHeadMinorVersion2 = 2,
    NVSAudioHeadMinorVersion3 = 3,
}NVSAudioHeadMinorVersion;

typedef enum {
    NVSAudioSampleRate96000   = 0,
    NVSAudioSampleRate88200   = 1,
    NVSAudioSampleRate64000   = 2,
    NVSAudioSampleRate48000   = 3,
    NVSAudioSampleRate44100   = 4,
    NVSAudioSampleRate32000   = 5,
    NVSAudioSampleRate24000   = 6,
    NVSAudioSampleRate22050   = 7,
    NVSAudioSampleRate16000   = 8,
    NVSAudioSampleRate12000   = 9,
    NVSAudioSampleRate11025   = 10,
    NVSAudioSampleRate8000    = 11,
    NVSAudioSampleRate7350    = 12,
}NVSAudioSampleRate;

typedef enum {
    NVSAUGraphCPULoadTypeMAX = 0,
    NVSAUGraphCPULoadTypeAVE = 1,
}NVSAUGraphCPULoadType;

typedef enum {
    NVSVideoChatNetTypeUnknown = 0,
    NVSVideoChatNetType3G      = 1,
    NVSVideoChatNetTypeWIFI    = 2,
    NVSVideoChatNetType2G      = 11,
    NVSVideoChatNetType4G      = 12,
}NVSVideoChatNetType;

typedef enum {
    NVSVideoChatISPTypeUnknow      = 0,
    NVSVideoChatISPTypeChinaTelcom = 1,
    NVSVideoChatISPTypeChinaUnicom = 2,
    NVSVideoChatISPTypeChinaMobile = 3,
}NVSVideoChatISPType;

typedef enum {
    NVSServerCfgRateArrayIndex2G      = 0,
    NVSServerCfgRateArrayIndex3G      = 1,
    NVSServerCfgRateArrayIndexWIFI    = 2,
    NVSServerCfgRateArrayIndex4G      = 3,
}NVSServerCfgRateArrayIndex;

typedef enum
{
    NVSSessionModeAudio         = 1,      //语音
    NVSSessionModeVideo         = 2,      //视频
} NVSSessionMode;

typedef enum {
    NVSLogLevelErr,
    NVSLogLevelWar,
    NVSLogLevelApp,
    NVSLogLevelPro,
}NVSLogLevel;

typedef enum {
    NVSClientTypeYiXin = 0, //易信客户端
    NVSClientTypeSupercall = 1, //超级电话客户端
    NVSClientTypeNIM = 2, //云信SDK
    NVSClientTypeNRTC = 3, //NRTC
    NVSClientTypeHS = 101, //恒生视频开户项目客户端
    NVSClientTypeCamera = 201, //易信摄像头
}NVSClientType;


typedef enum {
    NVSNetNotificationCommandKeyFrame   = 1,
}NVSNetNotificationCommand;

typedef enum {
    NVSLeaveReasonTimeout = -1,
    NVSLeaveReasonNormal  = 0,
}NVSLeaveReason;

typedef enum {
    NVSAudioErrorCategoryDevice,
    NVSAudioErrorCategoryCapture,
    NVSAudioErrorCategoryPlayback,
}NVSAudioErrorCategory;

typedef enum {
    NVSVideoQualityDefault = 0,
    NVSVideoQualityLow,
    NVSVideoQualityMedium,
    NVSVideoQualityHigh,
//    NVSVideoQualitySuperHigh,
}NVSVideoQuality;

#endif
