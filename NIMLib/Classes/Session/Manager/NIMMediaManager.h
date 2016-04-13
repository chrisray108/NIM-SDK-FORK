//
//  NIMMediaManager.h
//  NIMLib
//
//  Created by Xuhui on 15/2/26.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMMediaManagerProtocol.h"

@interface NIMMediaManager : NSObject <NIMMediaManager>

@property (nonatomic, weak) id<NIMMediaManagerDelgate> delegate;

@property (nonatomic, assign) NSTimeInterval recordProgressUpdateTimeInterval;

@end
