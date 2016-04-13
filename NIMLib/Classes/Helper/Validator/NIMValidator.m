//
//  NIMValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMValidator.h"
#import "NIMReplacableMessageValidator.h"


@interface NIMValidator ()
@property (nonatomic,strong)    NIMValidator    *realValidator;
@end

@implementation NIMValidator

+ (instancetype)validator:(id)object
{
    //这个地方猥琐一把,将真正的验证类内包裹在NIMValidator里面,这样可以hook所有的validator方法，实现统一的log输出
    NIMValidator *validator = [[NIMValidator alloc] init];
    validator.realValidator = [[[self class] alloc] init];
    validator.realValidator.object = object;
    return validator;
}

- (BOOL)isValid
{
    if (_realValidator)
    {
        BOOL valid = [_realValidator isValid];
        if (!valid && [_realValidator shouldLogError])
        {
            NIMLogWar(@"validator %@ failed object: % @",[_realValidator class],_realValidator.object);
        }
        return valid;
    }
    else
    {
        NIMAssert();
        return NO;
    }
}

- (BOOL)shouldLogError
{
    return YES;
}
@end


@interface NIMAndValidator ()
@property (nonatomic,strong) NSArray    *validators;
@end

@implementation NIMAndValidator

+ (instancetype)validator:(NSArray *)validators
{
    NIMAndValidator *validator = [[NIMAndValidator alloc] init];
    validator.validators = validators;
    return validator;
}

- (BOOL)isValid
{
    for (id validator in _validators)
    {
        if (![validator isKindOfClass:[NIMValidator class]] ||
            ![validator isValid])
        {
            return NO;
        }
    }
    return YES;
}

@end