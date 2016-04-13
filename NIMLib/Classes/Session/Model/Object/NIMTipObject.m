//
//  NIMTipObject.m
//  NIMLib
//
//  Created by chris on 15/11/4.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMTipObject.h"

@implementation NIMTipObject
@synthesize message   = _message;

- (NIMMessageType)type
{
    return NIMMessageTypeTip;
}


- (NSString *)encodeContent
{
    return nil;
}


- (void)decodeWithContent:(NSString*)content
{
    
}
@end
