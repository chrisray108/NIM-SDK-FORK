//
//  NIMUserManager.m
//  NIMLib
//
//  Created by amao on 8/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMUserManager.h"
#import "bind.h"
#import "user_protocol.h"
#import "friend_protocol.h"
#import "NIMGlobalDefs.h"
#import "NIMUser_Private.h"
#import "NIMDispatch.h"
#import "NIMProtocolUtil.h"
#import "NIMUserCallback.h"
#import "NIMUserInfo_Private.h"
#import "NIMUserRequestValidator.h"
#import "NIMUpdateMyUserInfoValidator.h"
#import "NIMArrayValidator.h"
#import "NIMUpdateUserRelationValidator.h"


@interface NIMUserManager ()
@end


@implementation NIMUserManager
- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - 对外接口
- (void)requestFriend:(NIMUserRequest *)request
           completion:(NIMUserBlock)block
{
    if (![NIMUserRequestValidator validator:request].isValid) {
        
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::FriendRequest req;
    req.uid_ = UTF8(request.userId);
    req.type_= (int32_t)request.operation;
    req.msg_ = UTF8(request.message);
    
    nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
    if (service) {
        NSInteger taskId = (NSInteger)service->Invoke_RequestFriend(req, nimbiz::GetNIMCallback());
        
        [self addUserCallback:block
                      forTask:taskId];
    }

    
}

- (void)deleteFriend:(NSString *)userId
          completion:(NIMUserBlock)block
{
    if (![userId isKindOfClass:[NSString class]]) {
        
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
    if (service) {
        NSInteger taskId = (NSInteger)service->Invoke_DeleteFriend(UTF8(userId), nimbiz::GetNIMCallback());
        
        [self addUserCallback:block
                      forTask:taskId];
    }

}

- (NSArray *)myFriends
{
    NSMutableArray *users = [NSMutableArray array];
    nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
    if (service) {
        std::list<nimbiz::UTF8String> list;
        service->GetMyFriends(list);
        for (auto it = list.begin(); it != list.end(); it++) {
            NIMUser *user = [[NIMUserManager sharedManager] userInfo:NSUTF8(*it)];
            [users addObject:user];
        }
    }
    return users;
}


- (void)addToBlackList:(NSString *)userId
            completion:(NIMUserBlock)block
{
    if (![userId isKindOfClass:[NSString class]]) {
        
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    [self updateUser:userId
               black:YES
          completion:block];
    
}


- (void)removeFromBlackBlackList:(NSString *)userId
                      completion:(NIMUserBlock)block
{
    if (![userId isKindOfClass:[NSString class]]) {
        
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    [self updateUser:userId
               black:NO
          completion:block];
    
}


- (BOOL)isUserInBlackList:(NSString *)userId
{
    NSAssert([userId isKindOfClass:[NSString class]], @"userId should be NSString class");
    BOOL isInBlackList = NO;
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        isInBlackList = service->IsUserInBlackList(UTF8(userId));
    }
    
    return isInBlackList;
}


- (NSArray *)myBlackList
{
    NSMutableArray *users = [NSMutableArray array];
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        std::list<nimbiz::UTF8String> uids;
        service->GetBlackList(uids);
        
        for (auto it = uids.begin(); it != uids.end(); it++) {
            NIMUser *user = [[NIMUserManager sharedManager] userInfo:NSUTF8(*it)];
            [users addObject:user];
        }
    }
    return users;
}


- (void)updateNotifyState:(BOOL)notify
                  forUser:(NSString *)userId
               completion:(NIMUserBlock)block
{
    if (![userId isKindOfClass:[NSString class]]) {
        
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        NSInteger taskId = (NSInteger)service->Invoke_UpdateMute(UTF8(userId), !notify, nimbiz::GetNIMCallback());
        
        [self addUserCallback:block
                      forTask:taskId];
    }
}


- (BOOL)notifyForNewMsg:(NSString *)userId
{
    if (![userId isKindOfClass:[NSString class]]) {
        NIMLogErr(@"invalid param");
        return NO;
    }
    BOOL notify = YES;
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        notify = !service->IsUserMute(UTF8(userId));
    }
    
    return notify;
}

- (NSArray *)myMuteUserList
{
    NSMutableArray *users = [NSMutableArray array];
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        std::list<nimbiz::UTF8String> uids;
        service->GetMuteList(uids);
        
        for (auto it = uids.begin(); it != uids.end(); it++) {
            NIMUser *user = [[NIMUserManager sharedManager] userInfo:NSUTF8(*it)];
            [users addObject:user];
        }
    }
    return users;
}

- (void)fetchUserInfos:(NSArray *)users
            completion:(NIMUserInfoBlock)block{

    BOOL paramIsValid = [[NIMArrayValidator validator:users] allObjectsAreKindOf:[NSString class]]
                         && users.count;
    if (!paramIsValid) {
        if (block) {
            block(nil,NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    std::list<nimbiz::UTF8String> uids;
    for (NSString *uid in users) {
        uids.push_back(UTF8(uid));
    }
    
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        std::list<nimbiz::UTF8String> list = uids;
        NSInteger taskId = (NSInteger)service->Invoke_FetchUsers(list, nimbiz::GetNIMCallback());
        [self addUserInfoCallback:block forTask:taskId];
    }

    
}

- (NIMUser *)userInfo:(NSString *)userId{
    if (![userId isKindOfClass:[NSString class]]) {
        NIMLogErr(@"userInfo: invalid param");
        return nil;
    }
    nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
    NIMUser *user;
    if (service) {
        nimbiz::Property property;
        //备注，扩展字段都是和friend关联的，这里直接取friend，取不到就说明是陌生人，直接塞一个uid进去
        service->GetFriendInfo(UTF8(userId),property);
        property.put_string(nimbiz::NIMUListTagId, UTF8(userId));
        user = [[NIMUser alloc] initWithProperty:property];
    }
    
    nimbiz::IUserService *infoService = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (user && infoService) {
        nimbiz::Property property;
        infoService->GetUserInfo(UTF8(userId), property);
        NIMUserInfo *userInfo = [NIMUserInfo userInfoWithProperty:property];
        user.userInfo = userInfo;
    }
    return user;
}


- (void)updateMyUserInfo:(NSDictionary *)values
              completion:(NIMUserBlock)block{
    BOOL valid = [NIMUpdateMyUserInfoValidator validator:values].isValid;
    if (!valid) {
        if (block) {
            block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        nimbiz::Property property;
        property.put_string(nimbiz::NIMUserInfoTagId, nimbiz::IYixinCore_Get()->GetUid());
        
        static NSArray *keys = @[@(NIMUserInfoUpdateTagNick),@(NIMUserInfoUpdateTagAvatar),@(NIMUserInfoUpdateTagSign),
                                 @(NIMUserInfoUpdateTagGender),@(NIMUserInfoUpdateTagEmail),@(NIMUserInfoUpdateTagBirth),@(NIMUserInfoUpdateTagMobile),
                                 @(NIMUserInfoUpdateTagEx)];
        
        for (NSNumber *key in values.allKeys) {
            if ([keys containsObject:key]) {
                id value = values[key];
                if ([value isKindOfClass:[NSString class]]) {
                    property.put_string((int32_t)[key integerValue], UTF8(values[key]));
                }else if ([value isKindOfClass:[NSNumber class]]){
                    property.put_int32((int32_t)[key integerValue], (int32_t)[value integerValue]);
                }
            }
        }
        NSInteger taskId = (NSInteger)service->Invoke_UpdateMyInfo(property, nimbiz::GetNIMCallback());
        [self addUserCallback:block
                      forTask:taskId];
    }

}

- (void)updateUser:(NIMUser *)user
        completion:(NIMUserBlock)block{
    BOOL valid = [NIMUpdateUserRelationValidator validator:user].isValid;
    if (!valid) {
        if (block) {
             block(NIMLocalError(NIMLocalErrorCodeInvalidParam));
        }
        return;
    }
    nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
    if (service) {
        nimbiz::Property property;
        property.put_string(nimbiz::NIMUListTagId, UTF8(user.userId));
        if (user.alias) {
            property.put_string(nimbiz::NIMUListTagAlias, UTF8(user.alias));
        }
        if (user.ext) {
            NSData *data  = [NSJSONSerialization dataWithJSONObject:user.ext options:0 error:nil];
            if (data) {
                NSString *ext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                property.put_string(nimbiz::NIMUListTagEx,UTF8(ext));
            }
        }
        NSInteger taskId = (NSInteger)service->Invoke_UpdateFriend(property, nimbiz::GetNIMCallback());
        [self addUserCallback:block
                      forTask:taskId];
    }

}



#pragma mark - callback
- (void)addUserCallback:(NIMUserBlock)block
                forTask:(NSInteger)taskId
{
    NIMUserCallback *callback = [[NIMUserCallback alloc] init];
    callback.block = block;
    
    [[NIMCallbackManager sharedManager] setCallback:callback
                                            forTask:taskId];
}

- (void)addUserInfoCallback:(NIMUserInfoBlock)block
                forTask:(NSInteger)taskId
{
    NIMUserInfoCallback *callback = [[NIMUserInfoCallback alloc] init];
    callback.block = block;
    
    [[NIMCallbackManager sharedManager] setCallback:callback
                                            forTask:taskId];
}


#pragma mark - misc
- (void)updateUser:(NSString *)userId
             black:(BOOL)black
        completion:(NIMUserBlock)block
{
    nimbiz::IUserService *service = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
    if (service) {
        NSInteger taskId = (NSInteger)service->Invoke_UpdateBlack(UTF8(userId), black, nimbiz::GetNIMCallback());
        [self addUserCallback:block
                      forTask:taskId];
    }
}


@end
