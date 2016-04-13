//
//  NIMTeamManager_Private.h
//  NIMLib
//
//  Created by amao on 12/3/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMTeamManager.h"

@interface NIMTeamManager (Private)
- (void)requestMissedMemberInfos:(NSString *)teamId
                      completion:(NIMTeamHandler)handler;

- (void)requestTeamMembers:(NSString *)teamId;
@end
