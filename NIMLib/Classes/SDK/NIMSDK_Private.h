//
//  NIMSDK_Private.h
//  NIMLib
//
//  Created by amao on 1/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMSDK.h"
#import "NIMPathManager.h"
#import "NIMLbsManager.h"
#import "NIMServerSetting.h"
#import "NIMAppTokenManager.h"


@interface NIMSDK ()
@property (nonatomic,strong)    NIMServerSetting    *setting;

@property (nonatomic,assign)    BOOL    consoleLogEnabled;

@property (nonatomic,copy)      NSString *localSessionId;

- (NSString *)apnsToken;
- (NSString *)apnsCerName;

- (NIMLbsManager *)lbsManager;
- (NIMAppTokenManager *)appTokenManager;


@end
