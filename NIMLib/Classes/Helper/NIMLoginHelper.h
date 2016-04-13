//
//  NIMLoginHelper.h
//  NIMLib
//
//  Created by amao on 1/4/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "document.h"


@class NIMLoginOperation;
@class NIMChatroomEnterRequest;

@interface NIMLoginHelper : NSObject
+ (nimbiz::Property)loginTags:(NIMLoginOperation *)operation;

+ (nimbiz::Property)chatroomTags:(NIMLoginOperation *)operation
                         request:(NIMChatroomEnterRequest *)request;

+ (BOOL)isNoretryCode:(NSInteger)code;
@end
