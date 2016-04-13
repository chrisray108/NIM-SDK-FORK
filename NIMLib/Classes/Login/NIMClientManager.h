//
//  NIMClientManager.h
//  NIMLib
//
//  Created by amao on 4/22/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NIMMultiLoginType){
    NIMMultiLoginTypeInit   =   1,
    NIMMultiLoginTypeLogin  =   2,
    NIMMultiLoginTypeLogout =   3,
};

@interface NIMClientManager : NSObject
- (NSArray *)currentClients;

- (void)onClientsChanged:(NSArray *)clients
                    type:(NIMMultiLoginType)type;

- (void)removeClientsByDeviceId:(NSArray *)deviceIds;

- (void)onLoginOK;
@end
