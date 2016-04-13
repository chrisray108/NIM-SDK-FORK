//
//  NIMLoginManager.h
//  NIMLib
//
//  Created by amao on 1/20/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginManagerProtocol.h"
#import "NIMLoginOperation.h"



@interface NIMLoginManager : NSObject<NIMLoginManager>
@property (nonatomic,strong)    NIMLoginOperation   *currentOperation;
+ (instancetype)sharedManager;
@end

namespace nimbiz
{
struct IAsynCallbackParam;
void    CallbackLogin(struct IAsynCallbackParam *loginParam);               //登录
void    CallbackLogout(struct IAsynCallbackParam *logoutParam);             //登出
void    CallbackKickout(struct IAsynCallbackParam *kickParam);              //被T
void    CallbackSync(struct IAsynCallbackParam *syncParam);                 //同步回调
void    CallbackUpdateOnlineState(struct IAsynCallbackParam *stateParam);   //更新状态
void    CallbackMultiLogin(struct IAsynCallbackParam *multiParam);          //多端登录
void    CallbackKickOther(struct IAsynCallbackParam *kickParam);            //主动T人
}