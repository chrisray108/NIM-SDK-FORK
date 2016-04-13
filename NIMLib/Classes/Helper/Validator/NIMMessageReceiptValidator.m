//
//  NIMMessageReceiptValidator.m
//  NIMLib
//
//  Created by amao on 2/29/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMMessageReceiptValidator.h"
#import "NIMMessageReceipt_Private.h"
#import "NSObject+NIM.h"
#import "NIMSessionValidator.h"

@implementation NIMMessageReceiptValidator
- (BOOL)isValid
{
    NIMMessageReceipt *receipt = [self.object nim_asObject:[NIMMessageReceipt class]];
    return receipt &&
           [[NIMSessionValidator validator:receipt.session] isValid] &&
           receipt.session.sessionType == NIMSessionTypeP2P;
}
@end
