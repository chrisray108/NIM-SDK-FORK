//
//  NIMNOSTokenManager.h
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNOSDefines.h"

typedef NS_ENUM(NSInteger, NIMNOSState)
{
    NIMNOSStateInit,
    NIMNOSStateUploading,
    NIMNOSStateUploaded,
};


@interface NIMNOSTokenManager : NSObject
+ (instancetype)sharedManager;
- (void)tryToRefreshToken;


- (NIMNOSToken *)tokenByMD5:(NSString *)md5;

- (void)saveToken:(NIMNOSToken *)token
           forMD5:(NSString *)md5;

- (void)removeTokenByMD5:(NSString *)md5;

- (NIMNOSToken *)fetchToken;

- (void)removeAllTokens;
@end
