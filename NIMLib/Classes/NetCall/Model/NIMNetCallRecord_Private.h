//
//  NIMNetCallRecord_Private.h
//  NIMLib
//
//  Created by chris on 15/5/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNetCallRecord.h"
#import "document.h"
@class NIMNetCallModel;

typedef NS_ENUM(NSInteger, NIMNetCallRecordStatus){
    NIMNetCallRecordStatusNone    = 0,
    NIMNetCallRecordStatusRead    = 1,
    NIMNetCallRecordStatusDeleted = 2,
};

@interface NIMNetCallRecord(){

}

@property (nonatomic,assign)  NSInteger serial;

@property (nonatomic,copy,readwrite)    NSString *recordId;

@property (nonatomic,assign,readwrite)  NIMNetCallEventType recordType;

@property (nonatomic,assign,readwrite)  NIMNetCallRecordStatus status;

@property (nonatomic,copy,readwrite)    NSString *from;

@property (nonatomic,assign,readwrite)  NSTimeInterval timestamp;

@property (nonatomic,assign,readwrite)  NSTimeInterval duration;

@property (nonatomic,copy,readwrite)  NSArray *members;

//转成Message必要的信息，只在第一次收到的时候有效，不会做本地存储
@property (nonatomic,copy) NSString *attach;

@property (nonatomic,copy) NSString *serverId;

@property (nonatomic,copy) NSString *senderName;


- (instancetype)initWithPorperty:(const nimbiz::Property &)property;


//生成一条电话记录
+ (instancetype)genCallRecord:(NIMNetCallModel *)call
                    eventType:(NIMNetCallEventType)eventType;

@end
