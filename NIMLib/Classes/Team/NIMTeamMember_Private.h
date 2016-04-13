//
//  NIMTeamMember_Private.h
//  NIMLib
//
//  Created by amao on 3/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTeamMember.h"
#import "document.h"

@interface NIMTeamMember()

@property(nonatomic,assign) NSTimeInterval createTime;

- (instancetype)initWithProperty:(const nimbiz::Property&)info;

@end
