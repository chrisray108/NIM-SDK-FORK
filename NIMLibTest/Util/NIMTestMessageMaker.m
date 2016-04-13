//
//  NIMTestMessageMaker.m
//  NIMLib
//
//  Created by chris on 15/12/24.
//  Copyright © 2015年 Netease. All rights reserved.
//

#import "NIMTestMessageMaker.h"
#import "NIMSDK.h"
#import "NIMMacros.h"
#import "NIMTestCustomObject.h"
#import "NIMTestMedialUtil.h"

@implementation NIMTestMessageMaker


#pragma mark - 有效消息
+ (NIMMessage *)msgWithText
{
    NIMMessage *message = [[NIMMessage alloc] init];
    message.text        = @([[NSDate date] timeIntervalSince1970]).stringValue;
    message.remoteExt   = @{ @"key1":@"remoteExt",
                                 @"key2":@(1),
                                 @"key3":@[],};
    message.localExt    = @{  @"key1":@"localExt",
                                 @"key2":@(1),
                                 @"key3":@[],};
    return message;
}

+ (NIMMessage *)msgWithImage
{
    UIImage *image = [NIMTestMedialUtil randomImage];
    NIMImageObject *object = [[NIMImageObject alloc] initWithImage:image];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = object;
    message.remoteExt   = @{ @"key1":@"remoteExt",
                                 @"key2":@(1),
                                 @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                                 @"key2":@(1),
                                 @"key3":@[],};
    return message;
}

+ (NIMMessage *)msgWithImageFile
{
    NSString *filepath = [NIMTestMedialUtil randomImageWithPath];
    NIMImageObject *object = [[NIMImageObject alloc] initWithFilepath:filepath];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = object;
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};
    return message;

}


+ (NIMMessage *)msgWithImageData
{
    NSData *data = UIImagePNGRepresentation([NIMTestMedialUtil randomImage]);
    NIMImageObject *object = [[NIMImageObject alloc] initWithData:data
                                                        extension:@"raw"];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.messageObject = object;
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};
    return message;
    
}

+ (NIMMessage *)msgWithAudio
{
    NSString *filepath = [NIMTestMedialUtil randomAudioWithPath];
    NIMAudioObject *object = [[NIMAudioObject alloc] initWithSourcePath:filepath];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.messageObject = object;
    return message;
}

+ (NIMMessage *)msgWithVideo
{
    NSString *filepath = [NIMTestMedialUtil randomVideoWithPath];
    NIMVideoObject *object = [[NIMVideoObject alloc] initWithSourcePath:filepath];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};

    message.messageObject = object;
    return message;
}


+ (NIMMessage*)msgWithLocation
{
    NIMLocationObject *locationObject = [[NIMLocationObject alloc] initWithLatitude:37.787359
                                                                          longitude:-122.408227
                                                                              title:@"地理位置消息"];
    
    NIMMessage *message               = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};

    message.messageObject             = locationObject;
    return message;
}


+ (NIMMessage *)msgWithNotification
{
    //本地不允许生成notification进行发送
    NIMNotificationObject *object = [[NIMNotificationObject alloc] init];
    
    NIMMessage *message               = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};

    message.messageObject             = object;
    return message;
}



+ (NIMMessage*)msgWithFile
{
    NSString *filepath = [NIMTestMedialUtil randomFileWithPath];
    NIMFileObject *object = [[NIMFileObject alloc] initWithSourcePath:filepath];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};

    message.messageObject = object;
    
    return message;
}


+ (NIMMessage *)msgWithTip
{
    NIMTipObject *object = [[NIMTipObject alloc] init];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};

    message.messageObject = object;
    message.text = @([[NSDate date] timeIntervalSince1970]).stringValue;;
    return message;
}

+ (NIMMessage *)msgWithCustom
{
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = [[NIMTestEmptyAttachment alloc] init];
    
    NIMMessage *message = [[NIMMessage alloc] init];
    message.remoteExt   = @{ @"key1":@"remoteExt",
                             @"key2":@(1),
                             @"key3":@[],};
    message.localExt   = @{  @"key1":@"localExt",
                             @"key2":@(1),
                             @"key3":@[],};

    message.messageObject = object;
    return message;
}



#pragma mark - 无效消息
+ (NIMMessage*)msgWithEmptyImage
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NIMImageObject * imageObject = [[NIMImageObject alloc] initWithImage:[UIImage new]];
    imageObject.displayName = [NSString stringWithFormat:@"图片发送于%@",dateString];
    NIMImageOption *option = [[NIMImageOption alloc] init];
    option.compressQuality = 0.8;
    NIMMessage *message          = [[NIMMessage alloc] init];
    message.messageObject        = imageObject;
    return message;
}


#pragma mark - Public API
+ (NSArray *)makeAllMessages
{
    return @[[NIMTestMessageMaker msgWithText],
             [NIMTestMessageMaker msgWithImage],
             [NIMTestMessageMaker msgWithImageFile],
             [NIMTestMessageMaker msgWithImageData],
             [NIMTestMessageMaker msgWithAudio],
             [NIMTestMessageMaker msgWithVideo],
             [NIMTestMessageMaker msgWithLocation],
             [NIMTestMessageMaker msgWithNotification],
             [NIMTestMessageMaker msgWithFile],
             [NIMTestMessageMaker msgWithTip],
             [NIMTestMessageMaker msgWithCustom]];
}

@end
