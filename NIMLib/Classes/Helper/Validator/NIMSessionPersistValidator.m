//
//  NIMSessionPersistValidator.m
//  NIMLib
//
//  Created by amao on 12/28/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMSessionPersistValidator.h"
#import "NIMMessage_Private.h"
#import "NIMSession_Private.h"
#import "NIMRecentSession_Private.h"

@implementation NIMSessionPersistValidator
- (BOOL)isValid
{
    NIMSession *session = nil;
    if ([self.object isKindOfClass:[NIMSession class]])
    {
        session = (NIMSession *)self.object;
    }
    else if ([self.object isKindOfClass:[NIMMessage class]])
    {
        session = (NIMSession *)[(NIMMessage *)self.object session];
    }
    else if ([self.object isKindOfClass:[NIMRecentSession class]])
    {
        session = (NIMSession *)[(NIMRecentSession *)self.object session];
    }
    if (session == nil)
    {
        NIMLogErr(@"invalid input for persister validator %@",self.object);
    }
    return session.sessionType != NIMSessionTypeChatroom;
}
@end
