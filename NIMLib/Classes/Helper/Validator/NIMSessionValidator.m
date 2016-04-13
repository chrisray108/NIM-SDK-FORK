//
//  NIMSessionValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMSessionValidator.h"
#import "NIMSession_Private.h"
#import "NSObject+NIM.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMSessionValidator
- (BOOL)isValid
{
    NIMSession *session = (NIMSession *)[self.object nim_asObject:[NIMSession class]];
    return session && [[NIMNonEmptyStringValidator validator:session.sessionId] isValid];
}
@end
