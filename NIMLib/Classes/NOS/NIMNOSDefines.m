//
//  NIMNOSDefines.m
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import "NIMNOSDefines.h"


@implementation NIMNOSToken
- (NSString *)description
{
    return [NSString stringWithFormat:@"token %@ bucket %@ object %@",_token,_bucketName,_objectName];
}

@end
