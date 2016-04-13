//
//  NIMManager.h
//  NIM
//
//  Created by amao on 11/13/13.
//  Copyright (c) 2013 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NIMManager <NSObject>
@optional
- (void)onReceiveMemoryWarning;
- (void)onEnterBackground;
- (void)onEnterForeground;
- (void)onAppWillTerminate;
@end

@interface NIMManager : NSObject<NIMManager>
+ (instancetype)sharedManager;

//空方法，只是输出log而已
//大部分的NIMManager懒加载即可，但是有些因为业务需要在登录后就需要立马生成
- (void)start;
@end



@interface NIMManagerCenter : NSObject
+ (id)sharedCenter;

- (void)createCenter;
- (void)destroyCenter;
@end
