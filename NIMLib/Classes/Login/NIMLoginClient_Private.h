//
//  NIMLoginClient.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginClient.h"
#import "document.h"

@interface NIMLoginClient ()
@property (nonatomic,copy)     NSString                *deviceId;
@property (nonatomic,assign)   NIMLoginClientType      type;
@property (nonatomic,copy)     NSString                *os;
@property (nonatomic,assign)   NSTimeInterval          timestamp;

- (instancetype)initWithProperty:(const nimbiz::Property &)property;
@end


@interface NIMAutoLoginData ()

@end