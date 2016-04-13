//
//  NIMKeyValueStore.h
//  YixinCall
//
//  Created by amao on 10/11/14.
//  Copyright (c) 2014 amao. All rights reserved.
//
//使用SQLite做的简易KeyValueStore
//适用场景: 1.需要实时序列化(比NSCoding后写文件效率高) 2.数据变动大(直接使用SQLite需要经常升级表)
//不使用LevelDB的原因是这个东西并不是为移动端开发专门设计,不太确定是否合适,所以自己造个轮子

#import <Foundation/Foundation.h>

@protocol NIMKeyValueProtocol <NSObject>
- (NSString *)key;
- (NSString *)value;
@end

//内部使用的KeyValueItem,如果不先自己实现NIMKeyValueProtocol协议,可以直接用这个类 (不推荐)
@interface NIMKeyValueItem : NSObject<NIMKeyValueProtocol>
@property (nonatomic,copy)      NSString    *key;
@property (nonatomic,copy)      NSString     *value;
@end



@interface NIMKeyValueStore : NSObject
+ (instancetype)storeByPath:(NSString *)path;

- (void)storeObject:(id<NIMKeyValueProtocol>)item;

- (void)removeObject:(id<NIMKeyValueProtocol>)item;
- (void)removeObjectByID:(NSString *)key;

- (id<NIMKeyValueProtocol>)objectByID:(NSString *)key;

- (NSArray *)allObjects;
- (void)removeAllObjects;
@end
