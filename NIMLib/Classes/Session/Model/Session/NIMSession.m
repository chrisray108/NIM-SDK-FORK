//
//  NIMSession.m
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSession_Private.h"

@implementation NIMSession
+ (instancetype)session:(NSString *)sessionId
                   type:(NIMSessionType)sessionType
{
    NIMSession *instance    = [[NIMSession alloc] init];
    instance.sessionId      = sessionId;
    instance.sessionType    = sessionType;
    return instance;
}

- (instancetype)copyWithZone:(NSZone *)zone{
   NIMSession * session     =  [[[self class] allocWithZone:zone] init];
    session.sessionId       = self.sessionId;
   session.sessionType      = self.sessionType;
   return session;
}

- (NSUInteger)hash{
    NSString * hashStr = [NSString stringWithFormat:@"%@%zd",self.sessionId,self.sessionType];
    return hashStr.hash;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NIMSession class]]) {
        return NO;
    }
    NIMSession * session = object;
    return session.sessionId &&
           self.sessionId &&
           [session.sessionId isEqualToString:self.sessionId] &&
           session.sessionType == self.sessionType;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"[session id %@ type %zd]",_sessionId,_sessionType];
}

- (NSString *)remoteSessionKey
{
    NSString *key = nil;
    switch (_sessionType) {
        case NIMSessionTypeP2P:
            key = [NSString stringWithFormat:@"p2p|%@",_sessionId];
            break;
        case NIMSessionTypeTeam:
            key = [NSString stringWithFormat:@"team|%@",_sessionId];
            break;
        default:
            NIMAssert();
            break;
    }
    return key;
}

@end


@implementation NIMSessionSaveResult

- (instancetype)init{
    self = [super init];
    if (self) {
        _savedMessages = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
