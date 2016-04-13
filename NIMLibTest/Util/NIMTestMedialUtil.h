//
//  NIMTestMedialUtil.h
//  NIMLib
//
//  Created by amao on 3/15/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NIMTestMedialUtil : NSObject

+ (UIImage *)randomImage;
+ (NSData *)randomImageWithData;
+ (NSString *)randomImageWithPath;

+ (NSString *)randomAudioWithPath;
+ (NSData *)randomAudioWithData;

+ (NSString *)randomVideoWithPath;
+ (NSData *)randomVideoWithData;

+ (NSString *)randomFileWithPath;
+ (NSData *)randomFileWithData;


@end
