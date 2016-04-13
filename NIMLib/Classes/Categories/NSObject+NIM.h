//
//  NSObject+NIM.h
//  NIMLib
//
//  Created by amao on 11/4/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NIM)
- (NSString *)nim_asString;

- (NSNumber *)nim_asNumber;

- (id)nim_asObject:(Class)convertClass;
@end
