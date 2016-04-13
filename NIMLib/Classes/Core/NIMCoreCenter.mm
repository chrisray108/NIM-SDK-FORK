//
//  NIMCoreCenter.m
//  YixinCall
//
//  Created by amao on 10/7/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMCoreCenter.h"
#import "string_util.h"
#import "bind.h"
#import "yixin_core.h"
#import "auth_protocol.h"
#import "sync_protocol.h"
#import "session_protocol.h"
#import "notify_protocol.h"
#import "team_protocol.h"
#import "netcall_protocol.h"
#import "misc_protocol.h"
#import "friend_protocol.h"
#import "user_protocol.h"
#import "chatroom_protocol.h"
#import "NIMLinkListener.h"
#import "NIMManager.h"
#import "NIMChatManager.h"
#import "NIMLoginManager.h"
#import "NIMTeamManager.h"
#import "NIMConversationManager.h"
#import "NIMSystemNotificationManager.h"
#import "NIMFeedbackCenter.h"
#import "NIMNetCallManager.h"
#import "NIMRTSManager.h"
#import "NIMUser_Private.h"
#import "NIMDispatch.h"
#import "NIMDelegateCenter.h"
#import "NIMUserInfo_Private.h"
#import "ios_util.h"
#import "NIMCallbackManager.h"
#import "NIMChatroomCallback.h"
#import "NIMChatroomManager.h"

namespace nimbiz
{
void CallbackUListChanged(UTF8String data_id, UTF8String item_id, TagSet tags, int event_id);
void CallbackRelationChanged(UTF8String data_id, UTF8String item_id, TagSet tags, int event_id);
void CallbackUserChanged(UTF8String data_id, UTF8String item_id, TagSet tags, int event_id);
}
@interface NIMCoreCenter ()
@end

@implementation NIMCoreCenter
+ (instancetype)sharedCenter
{
    static NIMCoreCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMCoreCenter alloc] init];
    });
    return instance;
}

- (void)start
{
    if (nimbiz::IYixinCore_Get() == NULL)
    {
        nimbiz::IYixinCore_Create();
        nimbiz::LoadPreLoginServices();
    
        
        nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
        
        nimbiz::IAuthService *auth = (nimbiz::IAuthService *)GetServiceFromCore(nimbiz::SVID_NIM_AUTH);
        if (auth)
        {
            nimbiz::IAsynCallback connectCallback = nbase::Bind(&nimbiz::CallbackConnectLink);
            auth->RegisterConnectCallback(connectCallback);
            
            nimbiz::IAsynCallback kickoutCallback = nbase::Bind(&nimbiz::CallbackKickout);
            auth->RegisterKickoutCallback(kickoutCallback);
            
            nimbiz::IAsynCallback multiCallback = nbase::Bind(&nimbiz::CallbackMultiLogin);
            auth->RegisterMultipLoginCallback(multiCallback);
            
        }
        
        nimbiz::IAsynCallback disconnectCallback = nbase::Bind(&nimbiz::CallbackDisconnectLink);
        core->RegisterDisConnectCallback(disconnectCallback);
                
        [[NIMLinkListener sharedListener] setState:NIMConnectStateInit];
        NIMLogApp(@"yixin core start");
    }
}

- (void)close
{
    nimbiz::IYixinCore_Close(0);
}

- (NSString *)currentUserID
{
    nimbiz::UTF8String uid;
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core)
    {
        uid = core->GetUid();
    }
#ifdef DEBUG
    if (uid.empty())
    {
        NIMLogErr(@"uid is empty");
    }
#endif
    return NSUTF8(uid);
}

- (void)setup:(NSString *)userID
{
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core != NULL)
    {
        NIMLogApp(@"setup core by %@",userID);
        core->SetUid(UTF8(userID));
        [self createCenter];
        [self registerCallbacks];
        [self addDocumentWatchers];
    }
    else
    {
        NIMAssert();
    }
}


- (void)beginToConnect
{
    nimbiz::IAuthService *service = (nimbiz::IAuthService *)GetServiceFromCore(nimbiz::SVID_NIM_AUTH);
    if (service)
    {
        service->Invoke_Connect();
    }
    else
    {
        NIMLogApp(@"core not ready");
    }
}

- (void)save
{
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core)
    {
        core->FlushDocument();
    }
}

- (BOOL)isInSync
{
    BOOL sync = NO;
    nimbiz::ISyncService *service = (nimbiz::ISyncService *)GetServiceFromCore(nimbiz::SVID_NIM_SYNC);
    if (service) {
        sync = service->IsInSync();
    }
    return sync;
}

#pragma mark - setup
- (void)createCenter
{
    [[NIMManagerCenter sharedCenter] createCenter];
}

- (void)registerCallbacks
{
    nimbiz::ISessionService *session = (nimbiz::ISessionService *)GetServiceFromCore(nimbiz::SVID_NIM_SESSION);
    if (session)
    {
        nimbiz::IAsynCallback sendCallback = nbase::Bind(&nimbiz::CallbackSendMsg);
        session->Register_SendMsgCallback(sendCallback);
        
        nimbiz::IAsynCallback recvCallback = nbase::Bind(&nimbiz::CallbackRecvMsgs);
        session->Register_RecvMsgsCallback(recvCallback);
        
        nimbiz::IAsynCallback recvSysCallback = nbase::Bind(&nimbiz::CallbackRecvSysMsgs);
        session->Register_RecvSysMsgsCallback(recvSysCallback);
        
        nimbiz::IAsynCallback sendNotificationCallback = nbase::Bind(&nimbiz::CallbackSendCustomNotification);
        session->Register_SendCustomNotificationCallback(sendNotificationCallback);
        
        nimbiz::IAsynCallback recvReceiptCallback = nbase::Bind(&nimbiz::CallbackRecvReceipt);
        session->Register_RecvMsgReceiptCallback(recvReceiptCallback);
        

    }
    
    nimbiz::INotifyService *notify = (nimbiz::INotifyService *)GetServiceFromCore(nimbiz::SVID_NIM_NOTIFY);
    if (notify)
    {
        nimbiz::IAsynCallback recvCallback = nbase::Bind(&nimbiz::CallbackRecvMsgs);
        notify->Register_RecvMsgsCallback(recvCallback);
        nimbiz::IAsynCallback notifyCallback = nbase::Bind(&nimbiz::CallbackReceiveNotify);
        notify->Register_RecvNetCallsCallback(notifyCallback);
    }
    
    nimbiz::ISyncService *sync = (nimbiz::ISyncService *)GetServiceFromCore(nimbiz::SVID_NIM_SYNC);
    if (sync)
    {
        nimbiz::IAsynCallback syncCallback = nbase::Bind(&nimbiz::CallbackSync);
        sync->RegisterSyncCallback(syncCallback);
    }
    
    nimbiz::ITeamService *team = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
    if (team)
    {
        nimbiz::IAsynCallback teamActionCallback = nbase::Bind(&nimbiz::CallbackTeamAction);
        team->RegisterActionCallback(teamActionCallback);
        
        nimbiz::IAsynCallback teamTlistChangedCallback = nbase::Bind(&nimbiz::CallbackTlistChanged);
        team->RegisterTlistChangedCallback(teamTlistChangedCallback);
        
        nimbiz::IAsynCallback teamInfoChangedCallback = nbase::Bind(&nimbiz::CallbackTInfoChanged);
        team->RegisterTInfoChangedCallback(teamInfoChangedCallback);
    }
    nimbiz::INetcallService *netcall = (nimbiz::INetcallService *)GetServiceFromCore(nimbiz::SVID_NIM_NETCALL);
    if (netcall) {
        nimbiz::IAsynCallback becalledCallback = nbase::Bind(&nimbiz::CallbackNetcallStartNotify);
        netcall->RegisterBeCalledCallback(becalledCallback);
        
        nimbiz::IAsynCallback calleeAckCallback = nbase::Bind(&nimbiz::CallbackNetcallCalleeAckNotify);
        netcall->RegisterRcvCalleeAckCallback(calleeAckCallback);
        
        nimbiz::IAsynCallback rcvHangupCallback = nbase::Bind(&nimbiz::CallbackNetcallHangupNotify);
        netcall->RegisterRcvHangupCallback(rcvHangupCallback);
        
        nimbiz::IAsynCallback controlCallback = nbase::Bind(&nimbiz::CallbackNetcallControlNotify);
        netcall->RegisterControlCallback(controlCallback);
        
        nimbiz::IAsynCallback netcallrecordCallback = nbase::Bind(&nimbiz::CallbackReceiveNotify);
        netcall->Register_RecvNetCallsCallback(netcallrecordCallback);
        
        nimbiz::IAsynCallback netcallRcvOtherAckCallback = nbase::Bind(&nimbiz::CallbackReceiveOtherAckNotify);
        netcall->Register_RecvOtherAckCallback(netcallRcvOtherAckCallback);
    }
    nimbiz::IRtsService *rts = (nimbiz::IRtsService *)GetServiceFromCore(nimbiz::SVID_NIM_RTS);
    if (rts) {
        nimbiz::IAsynCallback rtsTunReceivedCallback = nbase::Bind(&nimbiz::CallbackRtsTunReceivedNotify);
        rts->RegisterRtsTunReceivedCallback(rtsTunReceivedCallback);

        nimbiz::IAsynCallback rtsTunResponsedCallback = nbase::Bind(&nimbiz::CallbackRtsTunResponsedNotify);
        rts->RegisterRtsTunResponsedCallback(rtsTunResponsedCallback);
        
        nimbiz::IAsynCallback rtsTunClosedCallback = nbase::Bind(&nimbiz::CallbackRtsTunClosedNotify);
        rts->RegisterRtsTunClosedCallback(rtsTunClosedCallback);
        
        nimbiz::IAsynCallback rtsControlCallback = nbase::Bind(&nimbiz::CallbackRtsControlNotify);
        rts->RegisterRtsControlNotifyCallback(rtsControlCallback);
        
        nimbiz::IAsynCallback rtsTunSummaryCallback = nbase::Bind(&nimbiz::CallbackRtsTunSummaryNotify);
        rts->RegisterRtsTunSummaryCallback(rtsTunSummaryCallback);
        
        nimbiz::IAsynCallback rtsOtherResponsedCallback = nbase::Bind(&nimbiz::CallbackRtsOtherResponsedNotify);
        rts->RegisterRtsOtherResponsedCallback(rtsOtherResponsedCallback);
    }
    
    nimbiz::IMiscService *misc = (nimbiz::IMiscService *)GetServiceFromCore(nimbiz::SVID_NIM_MISC);
    if (misc) {
        nimbiz::IAsynCallback uploadCallback = nbase::Bind(&nimbiz::CallbackUploadLog);
        misc->RegisterUploadLogCallback(uploadCallback);
    }
    
    nimbiz::IChatroomService *chatroom =(nimbiz::IChatroomService *)GetServiceFromCore(nimbiz::SVID_NIM_CHATROOM);
    if (chatroom) {
        nimbiz::IAsynCallback sendCallback = nbase::Bind(&nimbiz::CallbackChatroomSendMsg);
        chatroom->Register_SendMsgCallback(sendCallback);
        
        nimbiz::IAsynCallback recvCallback = nbase::Bind(&nimbiz::CallbackChatroomRecvMsg);
        chatroom->Register_RecvMsgsCallback(recvCallback);
        
        nimbiz::IAsynCallback disconnectCallback = nbase::Bind(&nimbiz::CallbackDisconnectChatroom);
        chatroom->Register_DisconnectCallback(disconnectCallback);
        
        nimbiz::IAsynCallback kickCallback = nbase::Bind(&nimbiz::CallbackChatroomBeKicked);
        chatroom->Register_KickCallback(kickCallback);
    }
}

- (void)addDocumentWatchers
{
    nimbiz::IYixinCore *core = nimbiz::IYixinCore_Get();
    if (core == nil) {
        NIMLogErr(@"add document watcher");
        return;
    }
    
    if (!core->IsWatched()) {
        
        NIMLogApp(@"add document watch");
        
        if (nimbiz::HostUserInfos())
        {
            nimbiz::IWatchHandler ulistWatcher = nbase::Bind(&nimbiz::CallbackUListChanged);
            core->Watch(NULL, ulistWatcher, DN_FRIENDS);
            
            nimbiz::IWatchHandler userWatcher = nbase::Bind(&nimbiz::CallbackUserChanged);
            core->Watch(NULL, userWatcher, DN_USERS);
        }
        
        nimbiz::IWatchHandler relationWatcher = nbase::Bind(&nimbiz::CallbackRelationChanged);
        core->Watch(NULL, relationWatcher, DN_RELATION);
        

        core->SetWatached();
    }
    

    
}

@end


namespace nimbiz
{
#pragma mark - Document Watcher
void CallbackUListChanged(UTF8String data_id, UTF8String item_id, TagSet tags, int event_id)
{
    @autoreleasepool {
        
        nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
        NIMUser *user = nil;
        if (service) {
            nimbiz::Property property;
            service->GetFriendInfo(item_id,property);
            property.put_string(nimbiz::NIMUListTagId, item_id);
            user = [[NIMUser alloc] initWithProperty:property];
        }
        nimbiz::IUserService *infoService = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
        if (user && infoService) {
            nimbiz::Property property;
            infoService->GetUserInfo(item_id, property);
            NIMUserInfo *info = [NIMUserInfo userInfoWithProperty:property];
            user.userInfo = info;
        }
        
        if (user)
        {
            nim_main_async_safe(^{
                [[NIMDelegateCenter userDelegate] onFriendChanged:user];
            });
        }
    }
}

void CallbackRelationChanged(UTF8String data_id, UTF8String item_id, TagSet tags, int event_id)
{
    @autoreleasepool {

        BOOL blackListChanged = NO;
        for (auto it = tags.begin() ; it != tags.end(); it++){
            uint32_t tag = *it;
            if (tag == NIMRelationTagBlackList) {
                blackListChanged = YES;
                break;
            }
        }
        if (blackListChanged) {
            nim_main_async_safe(^{
                [[NIMDelegateCenter userDelegate] onBlackListChanged];
            });
        }
    }
}

void CallbackUserChanged(UTF8String data_id, UTF8String item_id, TagSet tags, int event_id)
{
    @autoreleasepool {
        NIMUser *user = nil;
        
        nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
        if (service)
        {
            nimbiz::Property property;
            service->GetFriendInfo(item_id,property);
            property.put_string(nimbiz::NIMUListTagId, item_id);
            user = [[NIMUser alloc] initWithProperty:property];
        }
        nimbiz::IUserService *infoService = (nimbiz::IUserService *)GetServiceFromCore(nimbiz::SVID_NIM_USER);
        if (user && infoService)
        {
            nimbiz::Property property;
            infoService->GetUserInfo(item_id, property);
            NIMUserInfo *info = [NIMUserInfo userInfoWithProperty:property];
            user.userInfo     = info;
        }
        

        if (user)
        {
            nim_main_async_safe(^{
                [[NIMDelegateCenter userDelegate] onUserInfoChanged:user];
            });

        }
     }
}

}
