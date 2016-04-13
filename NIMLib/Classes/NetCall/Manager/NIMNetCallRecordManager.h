//
//  NIMNetCallRecordManager.h
//  NIMLib
//
//  Created by amao on 3/25/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNetCallRecord.h"

@interface NIMNetCallRecordManager : NSObject
- (BOOL)saveCallRecord:(NIMNetCallRecord *)record;
@end
