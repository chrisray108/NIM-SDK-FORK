//
//  NSFileManager+NIM.h
//  NIMLib
//
//  Created by amao on 3/15/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (NIM)
- (BOOL)nim_copyFileAtPath:(NSString *)srcPath
                    toPath:(NSString *)dstPath
                     error:(NSError **)error;

@end
