//
//  NIMRecentSession.m
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMRecentSession_Private.h"
#import "NIMMessage.h"
@implementation NIMRecentSession

@synthesize lastMessage = _lastMessage;
@synthesize session     = _session;

+ (instancetype)recentSessionWithSession:(NIMSession *)session{
    NIMRecentSession * recentSession = [[NIMRecentSession alloc] init];
    recentSession.session = session;
    return recentSession;
}

+ (instancetype)recentSessionWithMessage:(NIMMessage *)message{
    NIMRecentSession * recentSession = [[NIMRecentSession alloc] init];
    recentSession.lastMessage = message;
    recentSession.session = message.session;
    return recentSession;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    NIMRecentSession *recent = [[[self class] alloc] init];
    recent.session = [self.session copy];
    recent.lastMessage = self.lastMessage;
    recent.unreadCount = self.unreadCount;
    return recent;
}

- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[NIMRecentSession class]]) {
        return NO;
    }
    NIMRecentSession *recent = object;
    NIMSession *session   = recent.session ?: recent.lastMessage.session;
    NIMSession *mySession = self.session ?: self.lastMessage.session;
    NIMMessage *message = recent.lastMessage;
    NIMMessage *myMessage = self.lastMessage;
    
    BOOL sameSession = session && mySession && [session isEqual:mySession];
    BOOL sameMessage = (message && myMessage && [message isEqual:myMessage]) || (message == nil && myMessage == nil);
    BOOL sameCount = self.unreadCount == recent.unreadCount;
    
    return sameSession && sameMessage && sameCount;
}


- (NSString*)description{
    NSMutableString *descriptionString = [NSMutableString stringWithString:@"****** "];
    [descriptionString appendFormat:@"NIMRecentSession %@ Info", [super description]];
    [descriptionString appendString:@" ******\n"];
    
    [descriptionString appendFormat:@" recent msg   : %@\n",   self.lastMessage.text];
    [descriptionString appendFormat:@" time         : %.2f\n", self.lastMessage.timestamp];

    [descriptionString appendString:@"****** NIMRecentSession End ******\n"];
    return descriptionString;
}

@end
