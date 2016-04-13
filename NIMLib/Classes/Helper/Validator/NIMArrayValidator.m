//
//  NIMArrayValidator.m
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "NIMArrayValidator.h"

@interface NIMArrayValidator ()
@property (nonatomic,strong)    NSArray *objects;
@end

@implementation NIMArrayValidator
+ (instancetype)validator:(NSArray *)array
{
    NIMArrayValidator *instance = [[NIMArrayValidator alloc] init];
    instance.objects = array;
    return instance;
}

- (BOOL)allObjectsAreKindOf:(Class)objectClass
{
    BOOL valid = [_objects isKindOfClass:[NSArray class]];
    if (valid)
    {
        for (id item in _objects)
        {
            if (![item isKindOfClass:objectClass])
            {
                return NO;
            }
        }
    }
    return valid;
}
@end
