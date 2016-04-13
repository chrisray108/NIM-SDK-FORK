//
//  NIMTestSystemNotificationMaker.h
//  NIMLib
//
//  Created by amao on 12/30/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMTestSystemNotificationMaker : NSObject
@property (nonatomic,strong)    NSDictionary    *notifications;
- (void)setUp;
- (void)tearDown;
@end
