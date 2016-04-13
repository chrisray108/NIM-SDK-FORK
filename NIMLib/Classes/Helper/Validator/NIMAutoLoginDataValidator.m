//
//  NIMAutoLoginDataValidator.m
//  NIMLib
//
//  Created by amao on 4/11/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMAutoLoginDataValidator.h"
#import "NIMLoginClient.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMAutoLoginDataValidator
- (BOOL)isValid
{
    NIMAutoLoginData *data = [self.object nim_asObject:[NIMAutoLoginData class]];
    return data &&
           [[NIMNonEmptyStringValidator validator:data.account] isValid] &&
           [[NIMNonEmptyStringValidator validator:data.token] isValid];
}
@end
