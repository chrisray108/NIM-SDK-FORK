//
//  NIMLoginClientValidator.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMLoginClientValidator.h"
#import "NIMLoginClient_Private.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMLoginClientValidator

- (BOOL)isValid
{
    NIMLoginClient *client = [self.object nim_asObject:[NIMLoginClient class]];
    return client && [[NIMNonEmptyStringValidator validator:client.deviceId] isValid];
}

@end
