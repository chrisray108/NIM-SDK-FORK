//
//  NIMLoginOperation.m
//  NIMLib
//
//  Created by amao on 1/29/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMLoginOperation.h"

@implementation NIMLoginOperation
- (NSString *)loginModeDescription
{
    NSString *description = nil;
    switch (_mode) {
        case NIMLoginModeManual:
            description = @"manual";
            break;
        case NIMLoginModeAuto:
            description = @"auto";
            break;
        default:
            NIMAssert();
            break;
    }
    return description;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"uid %@ app login mode %@ forced mode %d has handler %d",_account,[self loginModeDescription],_forcedMode,_handler != nil];
}

- (NSInteger)loginMode
{
    NIMLogApp(@"get login mode %@ forced mode %d",[self loginModeDescription],_forcedMode);
    return ( _mode == NIMLoginModeManual || _forcedMode ) ? 1 : 0;
}
@end
