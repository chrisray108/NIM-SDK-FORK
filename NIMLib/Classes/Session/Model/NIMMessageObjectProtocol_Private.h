//
//  NIMMessageObjectProtocol_Private.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMMessageObjectProtocol.h"
@class NIMMessageDownloadParam;
@protocol NIMMessageObject_Private <NIMMessageObject>
@required

//编码后的数据
- (NSString*)encodeContent;

//解码
- (void)decodeWithContent:(NSString*)content;


@optional

//消息发送前参数检查
- (NSError *)prepareForSend;

//消息下载前参数检查
- (NSError *)prepareForDownLoad;

//上传路径
- (NSString *)filepathForUpload;

//是否需要上传文件(以前有没有上传过)
- (BOOL)needUpload;

//文件下载参数(下载的Url,保存路径)
- (NIMMessageDownloadParam *)fileParamForDownload;

//设置上传Url
- (void)setUploadURL:(NSString *)urlString;

//上传Url
- (NSString*)uploadURL;

//收到消息后额外处理
- (void)saveDataAfterReceiving:(BOOL)online;

- (void)fireNotificationAfterReceiving;

//是否在添加消息的时候需要未读计数
- (BOOL)shouldIgnoreUnread;

@end



//SDK定义的MessageObject 序列化名字
//通用Tag
  /*文件*/
#define NIMMessageObjTagDisplayName     @"name"         //显示名
#define NIMMessageObjTagUrl             @"url"          //远程资源路径
#define NIMMessageObjTagPicWidth        @"w"            //图片宽
#define NIMMessageObjTagPicHeight       @"h"            //图片高
#define NIMMessageObjTagDuration        @"dur"          //时长
#define NIMMessageObjTagMD5             @"md5"          //md5
#define NIMMessageObjTagFileSize        @"size"         //文件大小
#define NIMMessageObjTagExt             @"ext"          //文件后缀

  /*位置*/
#define NIMMessageObjTagLatitude     @"lat"             //纬度
#define NIMMessageObjTagLongitude    @"lng"             //经度
#define NIMMessageObjTagAddress      @"title"           //位置


