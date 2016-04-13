//
//  NIMNOSUploader.h
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNOSDefines.h"


@interface NIMNOSUploader : NSObject

- (NSOperation *)upload:(NSString *)filepath
               progress:(NIMHttpProgressBlock)progress
             completion:(NIMUploadCompleteBlock)completion;

@end
