//
//  NIMFeedbackCenter.h
//  NIMLib
//
//  Created by amao on 7/7/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMFeedbackCenter : NSObject
+ (instancetype)sharedCenter;
- (void)feedback;
@end


namespace nimbiz
{
struct IAsynCallbackParam;
void    CallbackUploadLog(struct IAsynCallbackParam *param);
}