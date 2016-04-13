//
//  NIMUserCallback.m
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMUserCallback.h"
#import "NIMGlobalDefs.h"
#import "user_protocol.h"
#import "friend_protocol.h"
#import "NIMUser_Private.h"
#import "NIMUserInfo_Private.h"

@implementation NIMUserCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result{
    nimbiz::IAsynTaskCallbackParam *userParam = dynamic_cast<nimbiz::IAsynTaskCallbackParam *>(param);
    if (userParam)
    {
        result.error = NIMRemoteError(userParam->code_);
    }

}

- (void)run:(NIMCallbackResult *)result{
    if (_block)
    {
        _block(result.error);
    }
}

@end


@implementation NIMUserInfoCallback


- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result{
    nimbiz::CBUserInfoListParam *userParam = dynamic_cast<nimbiz::CBUserInfoListParam *>(param);
    if (userParam)
    {
        result.error = NIMRemoteError(userParam->code_);
        std::list<nimbiz::Property> list = userParam->userInfoList_;
        NSMutableArray *users = [[NSMutableArray alloc] init];
        nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
        if (service) {
            for (auto it = list.begin(); it != list.end(); it++)
            {
                nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
                NIMUserInfo *userInfo = [NIMUserInfo userInfoWithProperty:*it];
                
                nimbiz::Property property;
                service->GetFriendInfo(UTF8(userInfo.userId),property);
                property.put_string(nimbiz::NIMUListTagId, UTF8(userInfo.userId));
                NIMUser *user = [[NIMUser alloc] initWithProperty:property];
                user.userInfo = userInfo;
                
                [users addObject:user];
            }
        }
        result.resultObject = users;
    }
}

- (void)run:(NIMCallbackResult *)result{
    if (_block)
    {
        _block(result.resultObject,result.error);
    }
}

@end