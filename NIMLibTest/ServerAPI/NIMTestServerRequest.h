//
//  NIMTestServerRequest.h
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIMTestServerRequest <NSObject>
- (NSString *)name;
- (NSDictionary *)dict;
@end