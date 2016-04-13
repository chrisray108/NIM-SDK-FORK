//
//  NIMLoginOperation.h
//  NIMLib
//
//  Created by amao on 1/29/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginManagerProtocol.h"
#import "NIMLoginDefs.h"

@interface NIMLoginOperation : NSObject
@property (nonatomic,copy)      NSString        *account;       //第三方帐号
@property (nonatomic,copy)      NSString        *accountToken;  //第三方Token
@property (nonatomic,copy)      NIMLoginHandler handler;        //登录回调
@property (nonatomic,assign)    NIMLoginMode    mode;           //登录模式
@property (nonatomic,assign)    BOOL            forcedMode;     //强制登录模式

- (NSInteger)loginMode;
@end
