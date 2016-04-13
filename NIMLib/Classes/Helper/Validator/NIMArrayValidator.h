//
//  NIMArrayValidator.h
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMArrayValidator : NSObject
+ (instancetype)validator:(NSArray *)array;

- (BOOL)allObjectsAreKindOf:(Class)objectClass;
@end
