//
//  NIMNetCall.m
//  NIMLib
//
//  Created by chris on 15/5/7.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMNetCallRecord_Private.h"
#import "session_protocol.h"
#import "NSDictionary+NIMJson.h"
#import "NIMModelConverter.h"
#import "NIMUtil.h"
#import "NIMNetCallModel.h"
#import "NIMNetCallManager.h"

@implementation NIMNetCallRecord
- (instancetype)initWithPorperty:(const nimbiz::Property &)property{
    if (self = [super init])
    {
        _from   = NSUTF8(property.get_string(nimbiz::NIMSessionTagFromAccount));//拨打方id
        _attach = NSUTF8(property.get_string(nimbiz::NIMSessionTagAttach));
        _senderName = NSUTF8(property.get_string(nimbiz::NIMSessionTagNick));
        _serverId = NSUTF8(property.get_string(nimbiz::NIMSessionTagServerID));
        [self decodeAttach:_attach];
    }
    return self;
}

- (void)decodeAttach:(NSString *)attach{
    NSData *data = [attach dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            _recordType        = [dict nim_jsonInteger:@"id"];
            NSDictionary *data = [dict nim_jsonDict:@"data"];
            _recordId          = [data nim_jsonString:@"channel"];
            _timestamp         = NIMTimeLongToDouble([data nim_jsonLongLong:@"time"]);
            _duration          = [data nim_jsonDouble:@"duration"];
            _members           = [data nim_jsonArray:@"ids"];
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"serial %zd record_id %@ type %zd",self.serial,self.recordId,self.recordType];
}



+ (instancetype)genCallRecord:(NIMNetCallModel *)call
                    eventType:(NIMNetCallEventType)eventType

{
    NIMNetCallRecord *record = [[NIMNetCallRecord alloc] init];
    if (call.channelID) {
        record.recordId = @(call.channelID).stringValue;
    }else{
        record.recordId = call.uuid;
    }
    record.timestamp  = [NSDate date].timeIntervalSince1970;
    record.duration   = call.connectTimetag ? record.timestamp - call.connectTimetag : 0;
    record.recordType = eventType;
    nimbiz::IYixinCore *core  = nimbiz::IYixinCore_Get();
    NSString *myAccount = NSUTF8(core->GetUid());
    NSString *caller  = call.caller;
    NSArray  *callees = call.callees;
    if (!caller) {
        //说明自己是主叫方
        caller = myAccount;
        record.members = [@[myAccount] arrayByAddingObjectsFromArray:callees];
    }else{
        //说明自己是被叫方
        if (![callees containsObject:myAccount]) {
            callees = [@[myAccount] arrayByAddingObjectsFromArray:callees];
        }
        record.members = [callees arrayByAddingObjectsFromArray:@[caller]];
    }
    record.from = caller;
    NSString *attach  = [NIMNetCallRecord bulidLocalAttach:record callType:call.type];
    record.attach = attach;
    return record;
}



+ (NSString *)bulidLocalAttach:(NIMNetCallRecord *)record callType:(NIMNetCallType)callType{
    NSDictionary *attachDict = @{@"id":@(record.recordType),
                                 @"data":@{
                                          @"time":@(record.timestamp),
                                          @"duration":@(record.duration),
                                          @"calltype":@(callType),
                                          @"ids":record.members,
                                          @"from":record.from,
                                          @"channel":record.recordId
                                         }
                                 };
    NSString *attach;
    NSData *data = [NSJSONSerialization dataWithJSONObject:attachDict options:0 error:nil];
    if (data) {
        attach = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return attach;
}


@end
