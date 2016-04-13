//
//  NIMFileInfo.h
//  NIMLib
//
//  Created by amao on 5/4/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMResourceManagerProtocol.h"

@interface NIMFileCallback : NSObject
@property (nonatomic,copy)  NIMHttpProgressBlock        progress;
@property (nonatomic,copy)  NIMDownloadCompleteBlock    downloadBlock;
@property (nonatomic,copy)  NIMUploadCompleteBlock      uploadBlock;
@end


@interface NIMFileInfo : NSObject
@property (nonatomic,weak)      NSOperation *operation;
@property (nonatomic,assign)    NSInteger retryTimes;
- (void)addCallback:(NIMFileCallback *)callback;
- (NSArray *)callbacks;
@end