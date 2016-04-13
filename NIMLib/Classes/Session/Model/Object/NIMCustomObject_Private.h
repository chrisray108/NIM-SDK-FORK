//
//  NIMCustomObject_Private.h
//  NIMLib
//
//  Created by chris on 15/1/21.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMCustomObject.h"
#import "NIMMessageObjectProtocol_Private.h"

@interface NIMCustomObject ()<NIMMessageObject_Private>
- (BOOL)needsDownloadAttachment;
@end
