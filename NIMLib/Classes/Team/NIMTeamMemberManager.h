//
//  NIMTeamMemberManager.h
//  NIMLib
//
//  Created by amao on 12/3/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMManager.h"
#import "NIMTeamManagerProtocol.h"

@interface NIMTeamMemberManager : NSObject
- (void)fetchMissedMemberInfos:(NSString *)teamId
                    completion:(NIMTeamHandler)handler;
@end
