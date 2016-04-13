//
//  NIMKickClientCallback.h
//  NIMLib
//
//  Created by amao on 1/21/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginManagerProtocol.h"
#import "NIMCallbackManager.h"

typedef void(^NIMKickCallbackBlock)(NSError *error,NSArray *deviceIds);

@interface NIMKickClientCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMKickCallbackBlock    handler;
@end
