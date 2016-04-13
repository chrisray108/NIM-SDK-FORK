//
//  NIMNOSUploadTask.h
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNOSDefines.h"


@interface NIMNOSUploadTask : NSOperation
+ (instancetype)task:(NSString *)filepath
            progress:(NIMHttpProgressBlock)progress
            callback:(NIMUploadCompleteBlock)callback;
@end
