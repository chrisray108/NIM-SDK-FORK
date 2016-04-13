//
//  document_defs.h
//  NIMLib
//
//  Created by amao on 9/17/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#ifndef document_defs_h
#define document_defs_h

//这里定义了document的各个entry
//不可随意改动各个entry的定义,如果改动将会引起数据同步不全的问题
//有问题咨询 xiangwangfeng@corp.netease.com


//好友信息
#define DN_FRIENDS          "friends"    //如果APP选择托管好友关系则这个document有效

//用户关系
#define DN_RELATION         "relation"  //用户关系包括:是否需要有消息通知，是否被拉到黑名单

//用户信息
#define DN_USERS            "users"     //如果APP选择托管用户信息则这个document有效

//同步信息
#define DN_SYNC             "sync"      //同步信息里面记录的是各个service的同步时间戳


//群信息
#define DN_TINFO            "tinfo"     //群信息
#define DN_TLIST            "tlist"     //群列表

//会话信息
#define DN_SESSION          "session"   //会话信息
#endif
