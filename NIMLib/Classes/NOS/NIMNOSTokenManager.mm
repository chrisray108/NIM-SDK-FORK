//
//  NIMNOSTokenManager.m
//  NIMLib
//
//  Created by amao on 1/30/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMNOSTokenManager.h"
#import "yixin_core.h"
#import "bind.h"
#import "service.h"
#import "misc_protocol.h"
#import "NIMPathManager.h"
#import "NIMTaskEngine.h"
#import "NIMKeyValueStore.h"


#define YXMinTokenCacheCount    30
#define YXMinFetchTokenCount    50

namespace nimbiz
{
void    CallbackGetNosTokens(IAsynCallbackParam *tokenParam);
}

#pragma mark - NOSToken (NSKeyValue)
@interface NIMNOSToken (NIMStore)<NIMKeyValueProtocol>
@end

@implementation NIMNOSToken (NIMStore)
- (NSString *)key
{
    return self.token;
}



- (NSString *)value
{
    NSDictionary *dict = [self dictForToken];
    NSData *data =  [NSJSONSerialization dataWithJSONObject:dict
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
    return data ? [[NSString alloc] initWithData:data
                                        encoding:NSUTF8StringEncoding] : nil;
}

- (NSDictionary *)dictForToken
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.bucketName forKey:@"bucket"];
    [dict setValue:self.objectName forKey:@"object"];
    [dict setValue:self.token forKey:@"token"];
    [dict setValue:self.context forKey:@"context"];
    return dict;
}

+ (NIMNOSToken *)tokenByDict:(NSDictionary *)dict
{
    NIMNOSToken *token = [[NIMNOSToken alloc] init];
    token.bucketName = [dict objectForKey:@"bucket"];
    token.objectName = [dict objectForKey:@"object"];
    token.token      = [dict objectForKey:@"token"];
    token.context    = [dict objectForKey:@"context"];
    return token;
}

+ (NIMNOSToken *)tokenBy:(id<NIMKeyValueProtocol>)item
{
    NIMNOSToken *token = nil;
    NSData *data = [[item value] dataUsingEncoding:NSUTF8StringEncoding];
    if (data)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([dict isKindOfClass:[NSDictionary class]])
        {
            token = [NIMNOSToken tokenByDict:dict];
        }
    }
    return token;
}
@end





#pragma mark - NIMNOSTokenManager
@interface NIMNOSTokenManager ()
@property (nonatomic,strong)    NIMKeyValueStore *tokenStore;
@property (nonatomic,strong)    NIMKeyValueStore *md5Store;
@property (nonatomic,strong)    NSMutableArray *tokens;
@property (nonatomic,assign)    BOOL isQuery;
@end


@implementation NIMNOSTokenManager
+ (instancetype)sharedManager
{
    static NIMNOSTokenManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NIMNOSTokenManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        //构造token db
        NSString *tokenPath = [[[NIMPathManager sharedManager] sdkNosPath] stringByAppendingPathComponent:@"nos_token.db"];
        _tokenStore = [NIMKeyValueStore storeByPath:tokenPath];
        
        _tokens = [NSMutableArray array];
        NSArray *tokens =  [_tokenStore allObjects];
        for (id<NIMKeyValueProtocol>item in tokens)
        {
            NIMNOSToken *token = [NIMNOSToken tokenBy:item];
            if (token)
            {
                [_tokens addObject:token];
            }
        }
        
        
        //构造md5 db
        NSString *md5Path = [[[NIMPathManager sharedManager] sdkNosPath] stringByAppendingPathComponent:@"nos_md5.db"];
        _md5Store = [NIMKeyValueStore storeByPath:md5Path];
    }
    return self;
}

- (void)tryToRefreshToken
{
    @synchronized(self)
    {
        [self refreshToken];
    }
}

- (NIMNOSToken *)tokenByMD5:(NSString *)md5
{
    NIMNOSToken *token = nil;
    @synchronized(self)
    {
        id<NIMKeyValueProtocol> item = [_md5Store objectByID:md5];
        if (item)
        {
            NSData *data = [[item value] dataUsingEncoding:NSUTF8StringEncoding];
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:0];
                if ([dict isKindOfClass:[NSDictionary class]])
                {
                    token = [NIMNOSToken tokenByDict:dict];
                }
            }
        }
        if (token == nil)
        {
            token = [self token];
        }
    }
    return token;
}


- (void)saveToken:(NIMNOSToken *)token
           forMD5:(NSString *)md5
{
    if (md5 && token)
    {
        NIMKeyValueItem *item = [[NIMKeyValueItem alloc] init];
        item.key = md5;
        item.value = [token value];
        [_md5Store storeObject:item];
    }
}

- (void)removeTokenByMD5:(NSString *)md5
{
    if (md5)
    {
        [_md5Store removeObjectByID:md5];
    }
}

- (NIMNOSToken *)fetchToken
{
    NIMNOSToken *token = nil;
    @synchronized(self)
    {
        token = [self token];
    }
    return token;
}

- (void)removeAllTokens
{
    @synchronized(self)
    {
        [_tokens removeAllObjects];
        [self refreshToken];
    }
    [_tokenStore removeAllObjects];
}

- (void)updateTokens:(NSArray *)tokens
{
    if ([tokens count])
    {
        @synchronized(self)
        {
            [_tokens addObjectsFromArray:tokens];
        }
        for (NIMNOSToken *token in tokens)
        {
            [_tokenStore storeObject:token];
        }
    }
}

#pragma mark - misc
- (NIMNOSToken *)token
{
    NIMNOSToken *token = [_tokens lastObject];
    [_tokens removeLastObject];
    [_tokenStore removeObject:token];
    [self refreshToken];
    return token;
}


- (void)refreshToken
{
    if ([_tokens count] <  YXMinTokenCacheCount)
    {
        NIMLogApp(@"refresh nos token %zd",[_tokens count]);
        [self requestTokens];
    }
}

- (void)requestTokens
{
    nimbiz::IMiscService *service = (nimbiz::IMiscService *)GetServiceFromCore(nimbiz::SVID_NIM_MISC);
    if (service)
    {
         nimbiz::IAsynCallback callback = nbase::Bind(&nimbiz::CallbackGetNosTokens);
         service->Invoke_GetNOSToken(YXMinFetchTokenCount, callback);
    }
}
@end


#pragma mark - Callback
namespace nimbiz
{
void    CallbackGetNosTokens(IAsynCallbackParam *tokenParam)
{
    @autoreleasepool {
        CBGetTokenParam *param = (CBGetTokenParam *)tokenParam;
        if (param->tokens_.size())
        {
            NSMutableArray *tokens = [NSMutableArray array];
            for (auto it = param->tokens_.begin();
                 it != param->tokens_.end(); it++)
            {
                NIMNOSToken *token = [[NIMNOSToken alloc] init];
                token.bucketName    = NSUTF8(it->get_string(NIMNOSTokenTagBucket));
                token.objectName    = NSUTF8(it->get_string(NIMNOSTokenTagObject));
                token.token         = NSUTF8(it->get_string(NIMNOSTokenTagToken));
                [tokens addObject:token];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NIMNOSTokenManager sharedManager] updateTokens:tokens];
            });
        }
    }
}

}