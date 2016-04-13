//
//  NIMValidator.h
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NIM.h"


@interface NIMValidator : NSObject
+ (instancetype)validator:(id)object;
@property (nonatomic,strong)    id      object;
@property (nonatomic,assign)    BOOL    valid;
- (BOOL)isValid;
- (BOOL)shouldLogError;
@end


@interface NIMAndValidator : NSObject
+ (instancetype)validator:(NSArray *)validators;
- (BOOL)isValid;
@end

