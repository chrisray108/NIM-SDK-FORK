//
//  NSFileManager+NIM.m
//  NIMLib
//
//  Created by amao on 3/15/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NSFileManager+NIM.h"
#import "NIMNOSUtil.h"

@implementation NSFileManager (NIM)
- (BOOL)nim_copyFileAtPath:(NSString *)srcPath
                    toPath:(NSString *)dstPath
                     error:(NSError **)error
{
    
    if ([self fileExistsAtPath:dstPath]) {
        
        NSString *dstPathMD5 = [NIMNOSUtil fileMD5:dstPath];
        NSString *srcPahtMD5 = [NIMNOSUtil fileMD5:srcPath];
        if (srcPahtMD5 && dstPathMD5 && [srcPahtMD5 isEqualToString:dstPathMD5])
        {
            NIMLogApp(@"copy file %@ to %@ while file exists with same md5 %@",
                      srcPath,dstPath,srcPahtMD5);
            return YES;
        }
        else
        {
            return [self removeItemAtPath:dstPath error:error] &&
            [self copyItemAtPath:srcPath
                          toPath:dstPath
                           error:error];
        }
        
    }
    else
    {
        return [self copyItemAtPath:srcPath
                             toPath:dstPath
                              error:error];
    }
}
@end
