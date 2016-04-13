//
//  NIMAudioTrans.h
//  NIMLib
//
//  Created by amao on 7/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMMediaManagerProtocol.h"

@interface NIMAudioTrans : NSObject
- (void)trans:(NIMAudioToTextOption *)option
   completion:(NIMAudioToTextBlock)block;
@end
