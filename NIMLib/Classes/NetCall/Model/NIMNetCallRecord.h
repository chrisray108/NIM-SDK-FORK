//
//  NIMNetCall.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSDK.h"

@interface NIMNetCallRecord : NSObject

/**
 *  网络电话记录ID,唯一标识
 */
@property (nonatomic,copy,readonly)         NSString *recordId;


/**
 *  网络电话记录类型
 */
@property (nonatomic,assign,readonly)       NIMNetCallEventType recordType;


/**
 *  拨打方ID
 */
@property (nonatomic,copy,readonly)         NSString *from;

/**
 *  拨打时间
 */
@property (nonatomic,assign,readonly)       NSTimeInterval timestamp;

/**
 *  聊天成员id
 */
@property (nonatomic,copy,readonly)         NSArray *members;

/**
 *  通话时长
 */
@property (nonatomic,assign,readonly)       NSTimeInterval duration;


@end
