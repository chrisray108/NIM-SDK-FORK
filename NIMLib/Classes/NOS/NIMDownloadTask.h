//
//  NIMDownloadTask.h
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNOSDefines.h"

@interface NIMDownloadTask : NSOperation
+ (instancetype)task:(NSString *)urlString
            filepath:(NSString *)filepath
            progress:(NIMHttpProgressBlock)progress
          completion:(NIMDownloadCompleteBlock)completion;
@end
