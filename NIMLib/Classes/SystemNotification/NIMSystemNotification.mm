//
//  NIMSystemNotification.m
//  NIMLib
//
//  Created by amao on 3/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSystemNotification_Priviate.h"
#import "NSDictionary+NIMJson.h"
#import "NIMSystemNotificationManager.h"
#import "team_protocol.h"
#import "session_protocol.h"
#import "friend_protocol.h"
#import "NIMProtocolUtil.h"
#import "NIMSession_Private.h"
#import "NIMUser_Private.h"


@implementation NIMSystemNotification
- (instancetype)initWithPorperty:(const nimbiz::Property &)property
{
    if (self = [super init])
    {
        _msgId                  = property.get_uint64(nimbiz::NIMSystemMsgTagMsgID);
        _timestamp              = NIMTimeLongToDouble(property.get_uint64(nimbiz::NIMSystemMsgTagTime));
        _type                   = property.get_int32(nimbiz::NIMSystemMsgTagType);
        _sourceID               = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagFromAccount));
        _targetID               = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagToAccount));
        _postscript             = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagPostscript));
        _attachString           = NSUTF8(property.get_string(nimbiz::NIMSystemMsgTagAttach));

    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"serial %zd msg_id %lld type %zd",self.serial,self.msgId,self.type];
}

- (BOOL)isRead
{
    return _status == NIMNotificationStatusRead;
}

- (void)setRead:(BOOL)read
{
    if (read && _status == NIMNotificationStatusNone)
    {
        _status = NIMNotificationStatusRead;
    }
    else if(!read && _status == NIMNotificationStatusRead)
    {
        _status = NIMNotificationStatusNone;
    }
    else
    {
        NIMAssert();
        return;
    }
}

- (void)setHandleStatus:(NSInteger)handleStatus
{
    if (_handleStatus != handleStatus) {
        _handleStatus = handleStatus;
        [[NIMSystemNotificationManager sharedManager] updateNotificationSubStatus:self];
    }
}



- (id)attachment
{
    if (_attachmentObject == nil) {
        if (_type == NIMSystemNotificationTypeFriendAdd) {
            [self parseAddUserAttachment];
        }
    }
    return _attachmentObject;
}

- (void)parseAddUserAttachment
{
    if (_attachString)
    {
        NSData *data = [_attachString dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            if ([dict isKindOfClass:[NSDictionary class]]) {
            
                NIMUserOperation type = [dict nim_jsonInteger:@"vt"];
                _attachmentObject = [[NIMUserAddAttachment alloc] initWithOperation:type];
            }
        }
    }

}

- (BOOL)canSave{
    return self.type != NIMSystemNotificationTypeFriendDelete;
}

#pragma mark - 收到消息后的处理
- (void)saveDataAfterReceiving:(BOOL)online
{
    [self saveTeamInfo];
    
    if (online) {
        [self saveUList];
    }
    
}

- (void)saveTeamInfo
{
    if (_attachString)
    {
        NSData *data = [_attachString dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            if ([dict isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *tinfo = [dict nim_jsonDict:@"tinfo"];
                if (tinfo)
                {
                    nimbiz::Property property = [NIMProtocolUtil dictToProperty:tinfo];
                    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
                    if (service)
                    {
                        service->SaveTeamInfoFromServer(property);
                    }
                }
                
                NSDictionary *tlist = [dict nim_jsonDict:@"tlist"];
                if (tlist)
                {
                    nimbiz::Property property = [NIMProtocolUtil dictToProperty:tlist];
                    nimbiz::ITeamService *service = (nimbiz::ITeamService *)GetServiceFromCore(nimbiz::SVID_NIM_TEAM);
                    if (service)
                    {
                        nimbiz::UTF8String team_id = property.get_string(nimbiz::NIMTeamMemberTagTID);
                        std::list<nimbiz::Property> users;
                        users.push_back(property);
                        service->SaveTeamUsers(team_id, users , false);
                    }
                }
            }
        }
    }
}

- (void)saveUList
{
    if (_type == NIMSystemNotificationTypeFriendAdd) {
        
        id attachment = [self attachment];
        if ([attachment isKindOfClass:[NIMUserAddAttachment class]]) {
            if ([(NIMUserAddAttachment *)attachment operationType] == NIMUserOperationAdd ||
                [(NIMUserAddAttachment *)attachment operationType] == NIMUserOperationVerify)
            {
                [self updateUser:_sourceID
                    markAsFriend:YES];
            }
        }
    }
    else if(_type == NIMSystemNotificationTypeFriendDelete)
    {
        [self updateUser:_sourceID
            markAsFriend:NO];
    }
}

- (void)updateUser:(NSString *)userId
      markAsFriend:(BOOL)mark
{
    nimbiz::IFriendService *service = (nimbiz::IFriendService *)GetServiceFromCore(nimbiz::SVID_NIM_FRIEND);
    if (service) {
        service->MarkFriendTag(UTF8(userId), mark);
    }
}
@end



@implementation NIMUserAddAttachment
- (instancetype)initWithOperation:(NIMUserOperation)operation
{
    if (self = [super init]) {
        _operationType = operation;
    }
    return self;
}

@end


@implementation NIMSystemNotificationFilter



@end


