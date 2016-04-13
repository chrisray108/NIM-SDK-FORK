//
//  NIMTeam.m
//  NIMLib
//
//  Created by amao on 2/28/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMTeam_Private.h"
#import "team_protocol.h"
#import "NIMSDK_Private.h"

@implementation NIMTeam

- (instancetype)initWithProperty:(const nimbiz::Property&)info
{
    if (self = [super init])
    {
        _teamId             = NSUTF8(info.get_string(nimbiz::NIMTeamTagID));
        _teamName           = NSUTF8(info.get_string(nimbiz::NIMTeamTagName));
        _owner              = NSUTF8(info.get_string(nimbiz::NIMTeamTagOwner));
        _memberNumber       = (NSInteger)info.get_uint32(nimbiz::NIMTeamTagValidNumber);
        _createTime         = NIMTimeLongToDouble(info.get_uint64(nimbiz::NIMTeamTagCreateTime));
        _type               = (NSInteger)info.get_uint32(nimbiz::NIMTeamTagType);
        _intro              = NSUTF8(info.get_string(nimbiz::NIMTeamTagIntro));
        _announcement       = NSUTF8(info.get_string(nimbiz::NIMTeamTagAnnouncement));
        _level              = (NSInteger)info.get_uint32(nimbiz::NIMTeamTagLevel);
        _joinMode           = (NSInteger)info.get_uint32(nimbiz::NIMTeamTagJoinMode);
        _clientCustomInfo   = NSUTF8(info.get_string(nimbiz::NIMTeamTagClientCustom));
        _serverCustomInfo   = NSUTF8(info.get_string(nimbiz::NIMTeamTagServerCustom));
    }
    return self;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NIMTeam class]]) {
        return NO;
    }
    NIMTeam *team = object;
    return [team.teamId isEqualToString:self.teamId];
}


- (NSString *)description{
    NSMutableString *descriptionString = [NSMutableString stringWithString:@"****** "];
    [descriptionString appendFormat:@"NIMTeam %@ Info", [super description]];
    [descriptionString appendString:@" ******\n"];
    
    [descriptionString appendFormat:@" teamId        : %@\n", self.teamId];
    [descriptionString appendFormat:@" teamName      : %@\n",  self.teamName];
    [descriptionString appendFormat:@" teamType      : %zd\n", self.type];
    
    [descriptionString appendString:@"****** NIMTeam End ******\n"];
    return descriptionString;
}

- (BOOL)notifyForNewMsg
{
    return [[[NIMSDK sharedSDK] teamManager] notifyForNewMsg:_teamId];
}

@end


@implementation NIMCreateTeamOption

- (NSString *)description
{
    return [NSString stringWithFormat:@"|create team option name %@ type %zd intro %@ postscript %@|",_name,_type,_intro,_postscript];
}
@end


