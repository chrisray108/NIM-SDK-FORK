//
//  NIMApnsManager.m
//  NIMLib
//
//  Created by amao on 4/3/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMApnsManager.h"
#import "NIMPushNotificationSetting_Private.h"
#import "yixin_core.h"
#import "bind.h"
#import "user_protocol.h"
#import "sync_protocol.h"
#import "NIMGlobalDefs.h"
#import "NIMDispatch.h"
#import "NIMCallbackManager.h"

enum
{
    NIMDisturbingOpen = 1,
    NIMDisturbingClose= 2,
};


@interface NIMUpdateApnsCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMApnsHandler handler;
@end

@implementation NIMUpdateApnsCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBUpdateApnsParam *apnsParam = dynamic_cast<nimbiz::CBUpdateApnsParam *>(param);
    if (apnsParam)
    {
        result.error = NIMRemoteError(apnsParam->code_);
    }
}

- (void)run:(NIMCallbackResult *)result
{
    if (_handler) {
        _handler(result.error);
    }
}
@end



@interface NIMApnsManager ()
@end

@implementation NIMApnsManager
- (NIMPushNotificationSetting *)currentSetting
{
    NIMPushNotificationSetting *setting = [[NIMPushNotificationSetting alloc] init];
    nimbiz::ISyncService *sync = (nimbiz::ISyncService *)GetServiceFromCore(nimbiz::SVID_NIM_SYNC);
    if (sync)
    {
        nimbiz::Property info;
        sync->GetPushProperty(info);
        uint32_t value = info.get_uint32(nimbiz::NIMPushTagDetail);
        
        
        setting.type                = value >= NIMPushNotificationDisplayTypeDetail && value <= NIMPushNotificationDisplayTypeNoDetail ?
                                      (NIMPushNotificationDisplayType)value : NIMPushNotificationDisplayTypeDetail;
        setting.noDisturbing        = info.get_uint32(nimbiz::NIMPushTagOpen) == NIMDisturbingOpen;
        setting.noDisturbingStartH  = (NSUInteger)info.get_uint32(nimbiz::NIMPushTagFromH);
        setting.noDisturbingStartM  = (NSUInteger)info.get_uint32(nimbiz::NIMPushTagFromM);
        setting.noDisturbingEndH    = (NSUInteger)info.get_uint32(nimbiz::NIMPushTagToH);
        setting.noDisturbingEndM    = (NSUInteger)info.get_uint32(nimbiz::NIMPushTagToM);
        [setting verify];
    }
    return setting;
}

- (void)updateApnsSetting:(NIMPushNotificationSetting *)setting
               completion:(NIMApnsHandler)completion
{
    
    if (![setting isKindOfClass:[NIMPushNotificationSetting class]])
    {
        if (completion) {
            completion(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service)
    {
        [setting verify];
        
        nimbiz::Property info;
        uint32_t value = (setting.type >= NIMPushNotificationDisplayTypeDetail && setting.type <= NIMPushNotificationDisplayTypeNoDetail) ?
                        (uint32_t)setting.type : NIMPushNotificationDisplayTypeDetail;
        info.put_uint32(nimbiz::NIMPushTagDetail, value);
        info.put_uint32(nimbiz::NIMPushTagOpen, setting.noDisturbing ? NIMDisturbingOpen : NIMDisturbingClose);
        info.put_uint32(nimbiz::NIMPushTagFromH, (uint32_t)setting.noDisturbingStartH);
        info.put_uint32(nimbiz::NIMPushTagFromM, (uint32_t)setting.noDisturbingStartM);
        info.put_uint32(nimbiz::NIMPushTagToH, (uint32_t)setting.noDisturbingEndH);
        info.put_uint32(nimbiz::NIMPushTagToM, (uint32_t)setting.noDisturbingEndM);
        
        
        NSInteger taskId = (NSInteger)service->Invoke_UpdatePush(info, nimbiz::GetNIMCallback());
        NIMUpdateApnsCallback *callback = [NIMUpdateApnsCallback new];
        callback.handler = completion;
        
        [[NIMCallbackManager sharedManager] setCallback:callback
                                                forTask:taskId];
    }
}



@end

