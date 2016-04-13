//
//  NIMChatroomLoginData.h
//  NIMLib
//
//  Created by amao on 12/11/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatroomToken.h"
#import "NIMChatroomManagerProtocol.h"
#import "NIMLoginDefs.h"



@class NIMChatroomEnterRequest;


@interface NIMChatroomLoginOperation : NSObject

+ (instancetype)operationByRequest:(NIMChatroomEnterRequest *)request
                             token:(NIMChatroomToken *)token;

@property (nonatomic,copy,readonly) NSString *roomId;

@property (nonatomic,strong)    NIMChatroomEnterRequest *request;

@property (nonatomic,copy)      NSString    *linkId;

@property (nonatomic,assign)    NSInteger   loginTaskId;

@property (nonatomic,copy)      NIMChatroomEnterHandler loginHandler;

@property (nonatomic,assign)    NIMLoginMode mode;

- (NIMChatroomAddress *)address;
- (void)reportHostError:(BOOL)fatal;
@end
