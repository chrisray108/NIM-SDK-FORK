//
//  NIMGzipArchive.h
//  NIMLib
//
//  Created by amao on 7/8/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMGzipArchive : NSObject
+ (BOOL)gzipArchive:(NSString *)path
              files:(NSArray *)filepaths
            maxSize:(NSInteger)maxSize;
@end
