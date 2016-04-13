//
//  NIMFileCenter.h
//  NIMLib
//
//  Created by amao on 1/22/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNOSDefines.h"
#import "NIMResourceManagerProtocol.h"

@interface NIMFileCenter : NSObject<NIMResourceManager>

- (void)upload:(NSString *)filepath
      progress:(NIMHttpProgressBlock)progress
    completion:(NIMUploadCompleteBlock)completion;

- (void)download:(NSString *)urlString
        filepath:(NSString *)filepath
        progress:(NIMHttpProgressBlock)progress
      completion:(NIMDownloadCompleteBlock)completion;

- (void)cancelTask:(NSString *)filepath;
@end
