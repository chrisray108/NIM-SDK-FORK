//
//  NIMTestServerAPI.h
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTestServerRequest.h"
#import "NIMTestSendMsg.h"

typedef void(^NIMTestServerBlock)(NSError *error,id resultObject);

@interface NIMTestServerAPI : NSObject
+ (void)post:(id<NIMTestServerRequest>)request
  completion:(NIMTestServerBlock)completion;
@end
