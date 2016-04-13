//
//  NIMSDK_Private.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSDK_Private.h"
#import "NIMLoginManager.h"
#import "NIMMediaManager.h"
#import "NIMLbsManager.h"
#import "ios_util.h"
#import "NIMAppTokenManager.h"
#import "NIMBackgroundTaskRunner.h"
#import "NIMSDKConfig_Private.h"
#import "NIMFileCenter.h"
#import "NIMNetCallManagerWrapper.h"
#import "NIMRTSManagerWrapper.h"
#import "NIMSystemNotificationManagerWrapper.h"
#import "NIMChatManagerWrapper.h"
#import "NIMConversationManagerWrapper.h"
#import "NIMApnsManagerWrapper.h"
#import "NIMTeamManagerWrapper.h"
#import "NIMUserManagerWrapper.h"
#import "NIMChatroomManagerWrapper.h"
#import "core_task_id_generator.h"
#import "NIMUtil.h"


NSString *const NIMLocalErrorDomain = @"NIMLocalErrorDomain";
NSString *const NIMRemoteErrorDomain= @"NIMRemoteErrorDomain";

@interface NIMSDK ()
@property (nonatomic,strong)    NIMBackgroundTaskRunner *runner;

@end

@implementation NIMSDK
+ (instancetype)sharedSDK
{
    static NIMSDK *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMSDK alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        nimbiz::TaskIDGenerator::SharedInstance();
        [NIMPathManager sharedManager];
        NIMSetupLogger();
        
        
        
        _runner = [[NIMBackgroundTaskRunner alloc] init];
        _setting= [[NIMServerSetting alloc] init];
        _localSessionId = [NIMUtil uuid];
        
        
    }
    return self;
}

- (void)setSetting:(NIMServerSetting *)setting
{
    [_setting update:setting];
}

- (NSString *)sdkVersion
{
    return [[NIMSDKConfig sharedConfig] sdkPublicVersion];
}


- (void)registerWithAppID:(NSString *)appKey
                  cerName:(NSString *)cerName
{
    //设置TokenManager
    NIMAppTokenManager *tokenManager = [self appTokenManager];
    [tokenManager setAppKey:appKey];
    [tokenManager setApnsCerName:cerName];
    
    //设置AppKey到PathManager中
    NIMPathManager *pathManager = [NIMPathManager sharedManager];
    [pathManager setup:appKey];
    
    //输出Log
    NIMSDKConfig *config = [NIMSDKConfig sharedConfig];
    NSString *system = [NSString stringWithFormat:@"%@ %@ %@",
                        [[UIDevice currentDevice] model],
                        [[UIDevice currentDevice] systemName],
                        [[UIDevice currentDevice] systemVersion]];
    NIMLogApp(@"\nSDK started\napp key %@\nlocal session id %@\nsystem %@\nserver setting %@\nsdk config %@\nroot sdk attributes %@\n",
              appKey,_localSessionId,system,_setting,config,[pathManager sdkRootDirAttributes]);
    
    //请求Lbs
    [[self lbsManager] queryLbs];
}


- (NSString *)appKey
{
    return [[self appTokenManager] appKey];
}

- (BOOL)isUsingDemoAppKey
{
    NSString *appKey = [self appKey];
    return [appKey isEqualToString:@"fe416640c8e8a72734219e1847ad2547"] ||
           [appKey isEqualToString:@"45c6af3c98409b18a84451215d0bdd6e"];
}


- (void)updateApnsToken:(NSData *)token
{
    if (token)
    {
        NSString *deviceToken           = [NSString stringWithFormat:@"%@", token];
        NSCharacterSet *invalidSet      = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"] invertedSet];
        NSArray *validArray             = [deviceToken componentsSeparatedByCharactersInSet:invalidSet];
        NSString *formattedDeviceToken  = [validArray componentsJoinedByString:@""];
        
        if ([formattedDeviceToken length])
        {
            [[NIMAppTokenStore store] setApnsToken:formattedDeviceToken];
            [[self appTokenManager] sendToken];
        }
    }
}

- (NSString *)currentLogFilepath
{
    NSString *path = [[NIMPathManager sharedManager] sdkLogPath];
    NSString *filename = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                                              error:nil] lastObject];
    return [path stringByAppendingPathComponent:filename];
}

- (void)enableConsoleLog
{
    _consoleLogEnabled = YES;
}

- (id<NIMLoginManager>)loginManager
{
    return [NIMLoginManager sharedManager];
}

- (id<NIMChatManager>)chatManager
{
    return [NIMChatManagerWrapper sharedWrapper];
}

- (id<NIMConversationManager>)conversationManager
{
    return [NIMConversationManagerWrapper sharedWrapper];
}

- (id<NIMMediaManager>)mediaManager
{
    static NIMMediaManager *mediaManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaManager = [[NIMMediaManager alloc] init];
    });
    return mediaManager;
}

- (id<NIMUserManager>)userManager
{
    return [NIMUserManagerWrapper sharedWrapper];
}

- (id<NIMTeamManager>)teamManager
{
    return [NIMTeamManagerWrapper sharedWrapper];
}

- (id<NIMSystemNotificationManager>)systemNotificationManager
{
    return [NIMSystemNotificationManagerWrapper sharedWrapper];
}

- (id<NIMApnsManager>)apnsManager
{
    return [NIMApnsManagerWrapper sharedWrapper];
}

- (id<NIMResourceManager>)resourceManager
{
    static NIMFileCenter *fileCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileCenter = [[NIMFileCenter alloc] init];
    });
    return fileCenter;
}

- (id<NIMNetCallManager>)netCallManager
{
    return [NIMNetCallManagerWrapper sharedWrapper];
}

- (id<NIMRTSManager>)rtsManager
{
    return [NIMRTSManagerWrapper sharedWrapper];
}

- (id<NIMChatroomManager>)chatroomManager
{
    return [NIMChatroomManagerWrapper sharedWrapper];
}

#pragma mark - 内部接口
- (NSString *)apnsToken
{
    return [[NIMAppTokenStore store] apnsToken];
}

- (NSString *)apnsCerName
{
    return [[self appTokenManager] apnsCerName];
}

- (NIMLbsManager *)lbsManager
{
    static NIMLbsManager *lbsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lbsManager = [[NIMLbsManager alloc] init];
    });
    return lbsManager;
}

- (NIMAppTokenManager *)appTokenManager
{
    static NIMAppTokenManager *appTokenManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appTokenManager = [[NIMAppTokenManager alloc] init];
    });
    return appTokenManager;
}


@end
