// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/27
//
// This file defines the response error code of the interactive between client and server.

#ifndef PROTOCOL_RESPONSE_CODE_H_
#define PROTOCOL_RESPONSE_CODE_H_

namespace nimbiz
{
enum
{
    
    // 登录过程错误码
    NIMResSuccess             = 200,      // 没有错误，一切正常
    NIMResVersionError        = 201,      // 客户端版本不正确
    NIMResNotInvitedError     = 300,      // 用户没有被邀请
    NIMResBanError            = 301,      // 用户在黑名单中，禁止登录
    NIMResUidPassError        = 302,      // 用户名或密码错误
    NIMResUidExist            = 303,      // 要注册的帐号已存在
    NIMResUserRegistNotExist  = 304,      // 要注册的帐号不已存在
    NIMResTokenInvalid        = 306,      // Token失效
    
    
    NIMResIpBanError          = 310,      // 登录IP或MAC被封锁
    NIMResIpNotAllowed        = 315,      // 内部帐户不允许在该地址登录
    NIMResUIDOrPassError      = 316,      // 用户名不存在或密码错误
    NIMResLowVersion          = 317,      // 用户使用的版本过低
    
    NIMResForbidden           = 403,      // 用户被封禁
    NIMResNotExist            = 404,      // 请求的目标（用户或对象）不存在
    NIMResAccessError         = 405,      // 无权执行该操作
    NIMResNoModify            = 406,      // 数据距上次更新无修改
    NIMResTimeoutError        = 408,      // 请求过程超时
    
    NIMResVerifyError         = 413,      // 帐号或者验证码验证失败
    NIMResParameterError      = 414,      // 参数错误
    NIMResConnectionError     = 415,      // 网络连接出现错误
    NIMResFrequently          = 416,      // 操作太过频繁
    NIMResExist               = 417,      // 对象已经存在
    NIMResHttpError           = 418,      // http协议访问错误
    NIMResSizeLimit           = 419,      // 大小超过限制
    NIMResOpException         = 420,      // 操作出现异常
    NIMResOpCancel            = 421,      // 操作权限被取消了(用于非好友发消息和免费通话)
    
    NIMResUnknownError        = 500,      // 未知错误，或者不方便告诉你
    NIMResServerDataError     = 501,      // 服务器数据错误
    NIMResNotEnough           = 507,      // 不足
    NIMResDomainExpireOld     = 508,      // 超过期限
    NIMResInvalid             = 509,      // 已失效
    NIMResUserNotExist        = 510,      // 用户不存在
    
    NIMResTeamInitFailed      = 403,      // 初始成员不够
    NIMResTeamAccessError     = 802,      // 没有操作群的权限
    NIMResTeamNotExists       = 803,      // 群组不存在
    NIMResTeamMemberLimit     = 806,      // 超出群成员个数限制
    NIMResTeamApplySuccess    = 808,      // 申请成功，等待验证
    NIMResTeamAlreadyMember   = 809,      // 已经是群成员
    NIMResTeamNotMember       = 810,      // 不是群成员，或高级群邀请成功
    NIMResTeamBlackList       = 812,      // 在群黑名单中
    NIMResTeamInviteNeedVerify= 815,      //群成员超过40，并且邀请的人中，有需要验证的
    
    NIMResEPacket             = 999,      // 打包错误
    NIMResEUnpacket           = 998,      // 解包错误
    
    
    NIMResUPhotoNotExist      = 3100,     // 头像不存在
    NIMResUPhotoUpdateFailed  = 3101,     // 头像更新失败
    NIMResUPhotoNoChanged     = 3102,     // 头像信息无修改
    NIMResTPhotoNotExist      = 3103,     // 群头像不存在
    NIMResTPhotoNoChanged     = 3105,     // 群头像没有更新
    NIMResMailAccountError    = 4105,     // 帐号为null，提示参数错误
    
    NIMResEncounterBeReported = 4200,     //偶遇被举报了
    
    NIMResMailPasswordError   = 4505,     // 密码验证错误
    NIMResMailAccountLimit    = 4504,     // 绑定帐号超过服务器限制
    NIMResMailNeedUnbind      = 4502,     // 必须解绑后才可绑定新帐号提醒
    NIMResMailBindError       = 4501,     // 无绑定帐号，非法操作，其它同上
    NIMResMailCoremailError   = 500,      // 请求coremail绑定请求出错
    NIMResMailDBError         = 501,      // DB操作错误
    
    NIMResVerifyCodeError     = 20001,    // @weiliang 服务端的错误，发送验证码接口超时
    NIMResResisterUserToMany  = 20209,    // 注册用户数太多
    NIMResVerifyCodeSMSMinuteError  = 20221,    // 短信分钟频率限制
    NIMResVerifyCodeTelMinuteError  = 20222,    // 电话分钟频率限制
    NIMResVerifyCodeSMSDayError  = 20223,    // 短信日频率限制
    NIMResVerifyCodeTelDayError  = 20224,    // 电话日频率限制
    
    NIMResNetCallOtherHandled    = 9103,     //这通网络通话已经被其他端处理了

};

//关键字过滤错误码
enum  
{
    NIMResFilterError     =   1100,   //关键字过滤错误
    NIMResFilterWarning   =   1101,   //关键字过滤警告
};
    
}

#endif
