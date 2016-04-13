//
//  NIMTeamNotificationContent.h
//  NIMLib
//
//  Created by amao on 7/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTeamNotificationContent.h"
#import "NIMNotificationContent_Private.h"

@interface NIMTeamNotificationContent ()
@property (nonatomic,strong)   NSDictionary *groupInfo;
@property (nonatomic,assign)   NIMTeamOperationType  operationType;
@property (nonatomic,strong)   NSArray *targetIDs;
@property (nonatomic,strong)   id attachment;
@property (nonatomic,assign)   BOOL shouldRefreshTList;
@property (nonatomic,strong)   NSArray *infos;
- (void)saveDataAfterReceiving:(BOOL)online;
@end

@interface NIMUpdateTeamInfoAttachment ()
- (instancetype)initWithValues:(NSDictionary *)dict;
@end