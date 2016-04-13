//
//  NIMNOSDefines.h
//  YixinCall
//
//  Created by amao on 12/26/14.
//  Copyright (c) 2014 amao. All rights reserved.
//

//API参考: http://doc.hz.netease.com/pages/viewpage.action?pageId=38691638

#import <Foundation/Foundation.h>
#import "NIMResourceManagerProtocol.h"

@interface NIMNOSToken : NSObject
@property (nonatomic,copy  )      NSString    *token;
@property (nonatomic,copy  )      NSString    *bucketName;
@property (nonatomic,copy  )      NSString    *objectName;
@property (nonatomic,copy)        NSString    *context;

@end


