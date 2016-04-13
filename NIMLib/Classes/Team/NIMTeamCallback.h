//
//  NIMTeamCallback.h
//  NIMLib
//
//  Created by amao on 3/19/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "team_protocol.h"



@interface NIMTeamCallback : NSObject
- (void)setBlock:(id)block
         forTask:(NSInteger)taskID;

- (void)raiseCallabck:(nimbiz::CBTeamParam *)param;
@end
