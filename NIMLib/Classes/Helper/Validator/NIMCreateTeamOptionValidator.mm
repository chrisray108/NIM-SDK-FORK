//
//  NIMCreateTeamOptionValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMCreateTeamOptionValidator.h"
#import "NIMTeam_Private.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMCreateTeamOptionValidator
- (BOOL)isValid
{
    NIMCreateTeamOption *option = (NIMCreateTeamOption *)[self.object nim_asObject:[NIMCreateTeamOption class]];
    return  option &&
    [[NIMNonEmptyStringValidator validator:option.name] isValid] &&
    option.type >= NIMTeamTypeNormal &&
    option.type <= NIMTeamTypeAdvanced &&
    option.joinMode >= NIMTeamJoinModeNoAuth &&
    option.joinMode <=NIMTeamJoinModeRejectAll;
}
@end
