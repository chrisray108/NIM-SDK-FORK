//
//  NIMTeamCallback.m
//  NIMLib
//
//  Created by amao on 3/19/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTeamCallback.h"
#import "NIMDispatch.h"
#import "NIMGlobalDefs.h"
#import "NIMTeam_Private.h"
#import "NIMTeamMember_Private.h"
#import "NIMTeamManager.h"

@interface NIMTeamCallback ()
@property (nonatomic,strong)    NSMutableDictionary *callbacks;
@end

@implementation NIMTeamCallback

- (instancetype)init
{
    if (self = [super init])
    {
        _callbacks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setBlock:(id)block
         forTask:(NSInteger)taskID
{
    nim_main_async_safe(^(){
    if (block)
    {
        [_callbacks setObject:[block copy]
                       forKey:@(taskID)];
    }});
}

- (void)raiseCallabck:(nimbiz::CBTeamParam *)param
{
    NSInteger taskID = (NSInteger)param->task_id_;
    NSInteger type = (NSInteger)param->type_;
    NSInteger code = (NSInteger)param->code_;
    NSError *error = NIMRemoteError(code);
    id data = code == nimbiz::NIMResSuccess ? [self dataFrom:type
                                                 any:param->any_] : nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self raiseCallback:taskID
                       type:type
                      error:error
                       data:data];
    });
}

- (void)raiseCallback:(NSInteger)taskID
                 type:(NSInteger)type
                error:(NSError *)error
                 data:(id)data
{
    id obj = [[_callbacks objectForKey:@(taskID)] copy];
    NIMLogApp(@"on team action callback %zd type %zd error %@ callback %@",taskID,type,error,obj);
    if (obj)
    {
        switch (type) {
            case nimbiz::NIMTeamActionTypeCreate:
            {
                NSString *teamId = [data isKindOfClass:[NSString class]] ? data : nil;
                ((NIMTeamCreateHandler)obj)(error,teamId);
            }
                break;
            case nimbiz::NIMTeamActionTypeInvite:{
                NSArray *members = [data isKindOfClass:[NSArray class]] ? data : nil;
                ((NIMTeamMemberHandler)obj)(error,members);
            }
                break;
            case nimbiz::NIMTeamActionTypeRefreshMembers:{
                NSArray *members = [data isKindOfClass:[NSArray class]] ? data : nil;
                //排个序
                members = [members sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NIMTeamMember *member1 = obj1;
                    NIMTeamMember *member2 = obj2;
                    return member1.createTime > member2.createTime ? NSOrderedDescending : NSOrderedAscending;
                }];
                ((NIMTeamMemberHandler) obj)(error,members);
            }
                break;
            case nimbiz::NIMTeamActionTypeApply:{
                NSNumber *stauts = [data isKindOfClass:[NSNumber class]] ? data : nil;
                ((NIMTeamApplyHandler) obj)(error,stauts.integerValue);
            }
                break;
            case nimbiz::NIMTeamActionTypeApplyPass:{
                NSNumber *stauts = [data isKindOfClass:[NSNumber class]] ? data : nil;
                ((NIMTeamApplyHandler) obj)(error,stauts.integerValue);
            }
                break;
            case nimbiz::NIMTeamActionTypeDismiss:
            case nimbiz::NIMTeamActionTypeKick:
            case nimbiz::NIMTeamActionTypeLeave:
            case nimbiz::NIMTeamActionTypeUpdateTeamInfo:
            case nimbiz::NIMTeamActionTypeApplyReject:
            case nimbiz::NIMTeamActionTypeAddManager:
            case nimbiz::NIMTeamActionTypeRemoveManager:
            case nimbiz::NIMTeamActionTypeTransferOwner:
            case nimbiz::NIMTeamActionTypeRejectInvite:
            case nimbiz::NIMTeamActionTypeUpdateMyTList:
            case nimbiz::NIMTeamActionTypeUpdateOtherTList:
            case nimbiz::NIMTeamActionTypeAcceptInvite:{
                ((NIMTeamHandler)obj)(error);
            }
                break;
            case nimbiz::NIMTeamActionTypeFetchTeamInfo:{
                NIMTeam *team = [data isKindOfClass:[NIMTeam class]] ? data : nil;
                ((NIMTeamFetchInfoHandler ) obj)(error,team);
            }
                break;
            default:
                break;
        }
        [_callbacks removeObjectForKey:@(taskID)];
    }
}



- (id)dataFrom:(NSInteger)type
           any:(nimboost::any)any
{
    id data = nil;
    switch (type) {
        case nimbiz::NIMTeamActionTypeCreate:
            data = NSUTF8(nimboost::any_cast<nimbiz::UTF8String>(any));
            break;
        case nimbiz::NIMTeamActionTypeRefreshMembers:{
            std::list<nimbiz::Property> list = (nimboost::any_cast<std::list<nimbiz::Property> >(any));
            NSMutableArray * array = [[NSMutableArray alloc] init];
            for (auto it = list.begin(); it != list.end(); it++)
            {
                NIMTeamMember *member = [[NIMTeamMember alloc] initWithProperty:*it];
                [array addObject:member];
            }
            data = array;
            break;
        }
        case nimbiz::NIMTeamActionTypeInvite:{
            std::list<nimbiz::Property> list = (nimboost::any_cast<std::list<nimbiz::Property> >(any));
            NSMutableArray * array = [[NSMutableArray alloc] init];
            for (auto it = list.begin(); it != list.end(); it++)
            {
                NIMTeamMember *member = [[NIMTeamMember alloc] initWithProperty:*it];
                [array addObject:member];
            }
            data = array;
            break;
        }
        case nimbiz::NIMTeamActionTypeApply:{
            nimbiz::LinkFrame lf = nimboost::any_cast<nimbiz::LinkFrame>(any);
            NIMTeamApplyStatus status;
            switch (lf.error_) {
                case nimbiz::NIMResSuccess:
                    status = NIMTeamApplyStatusAlreadyInTeam;
                    break;
                case nimbiz::NIMResTeamApplySuccess:
                    status = NIMTeamApplyStatusWaitForPass;
                    break;
                default:
                    status = NIMTeamApplyStatusInvalid;
                    break;
            }
            data = @(status);
            break;
        }
        case nimbiz::NIMTeamActionTypeApplyPass:{
            nimbiz::LinkFrame lf = nimboost::any_cast<nimbiz::LinkFrame>(any);
            NIMTeamApplyStatus status;
            switch (lf.error_) {
                case nimbiz::NIMResTeamAlreadyMember:
                    status = NIMTeamApplyStatusAlreadyInTeam;
                    break;
                default:
                    status = NIMTeamApplyStatusInvalid;
                    break;
            }
            data = @(status);
            break;
        }
        case nimbiz::NIMTeamActionTypeFetchTeamInfo:{
            nimbiz::Property info = nimboost::any_cast<nimbiz::Property>(any);
            data = [[NIMTeam alloc] initWithProperty:info];
        }
            break;
        default:
            break;
    }
    return data;
}



@end
