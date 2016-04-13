//
//  NIMAudioToTextOptionValidator.m
//  NIMLib
//
//  Created by amao on 1/21/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMAudioToTextOptionValidator.h"
#import "NIMMediaManagerProtocol.h"
#import "NIMNonEmptyStringValidator.h"

@implementation NIMAudioToTextOptionValidator
- (BOOL)isValid
{
    NIMAudioToTextOption *option = [self.object nim_asObject:[NIMAudioToTextOption class]];
    return option &&
          [[NIMNonEmptyStringValidator validator:option.url] isValid] &&
          [[NIMNonEmptyStringValidator validator:option.filepath] isValid] &&
          [[NSFileManager defaultManager] fileExistsAtPath:option.filepath];

}
@end
