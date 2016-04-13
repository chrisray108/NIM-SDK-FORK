//
//  NIMCallbackManager.h
//  NIMLib
//
//  Created by amao on 9/16/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMManager.h"
#import "service.h"
#import "NIMGlobalDefs.h"

@interface NIMCallbackResult : NSObject
@property (nonatomic,strong)    NSError *error;
@property (nonatomic,strong)    id resultObject;
@end


@protocol NIMCallback <NSObject>
@required
- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result;

- (void)run:(NIMCallbackResult *)result;
@end



@interface NIMCallbackManager : NIMManager
- (void)setCallback:(id<NIMCallback>)object
            forTask:(NSInteger)taskId;
@end


namespace nimbiz
{
    IAsynCallback GetNIMCallback();
}