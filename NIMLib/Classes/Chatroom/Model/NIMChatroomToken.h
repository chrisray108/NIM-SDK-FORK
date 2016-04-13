//
//  NIMChatroomToken.h
//  NIMLib
//
//  Created by amao on 12/15/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMChatroomAddress : NSObject
@property (nonatomic,copy)      NSString    *ip;
@property (nonatomic,assign)    NSInteger   port;
@end


@interface NIMChatroomToken : NSObject
+ (instancetype)tokenBy:(NSArray *)addresses
                 roomId:(NSString *)roomId;

- (NIMChatroomAddress *)address;
- (void)reportHostError:(BOOL)fatal;
@end
