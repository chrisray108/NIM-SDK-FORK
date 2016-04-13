//
//  NIMLbsManager.m
//  NIMLib
//
//  Created by amao on 3/23/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMLbsManager.h"
#import "NSDictionary+NIMJson.h"
#import "NIMReachability.h"
#import "NIMSDK_Private.h"
#import "NIMTimer.h"
#import "NIMDispatch.h"
#import "NIMHostSwitcher.h"
#import "NIMLbsConfig.h"
#import "NIMAppLbsConfig.h"
#import "NIMNosLbsConfig.h"


@implementation NIMLinkAddress
@end




@interface NIMLbsManager ()<NIMTimerDelegate>
@property (nonatomic,strong)    NIMHostSwitcher *appSwitcher;
@property (nonatomic,strong)    NIMAppLbsConfig *appConfig;

@property (nonatomic,strong)    NIMHostSwitcher *nosSwitcher;
@property (nonatomic,strong)    NIMNosLbsConfig *nosConfig;

@property (nonatomic,copy)      NSString *nosDLAddress;
@end

@implementation NIMLbsManager
- (instancetype)init
{
    if (self = [super init])
    {
        NIMServerSetting *setting = [[NIMSDK sharedSDK] setting];
        
        NSString *linkAddress = [setting linkAddress];
        _appSwitcher = [NIMHostSwitcher switcher:NIMLbsTypeLink
                                     defaultHost:linkAddress
                                     maxErrTimes:3];
        _appConfig = [[NIMAppLbsConfig alloc] init];
        
        
        NSString *nosUploadAddress = [setting nosUploadAddress];
        _nosSwitcher =[NIMHostSwitcher switcher:NIMLbsTypeNOS
                                    defaultHost:nosUploadAddress
                                    maxErrTimes:3];
        _nosConfig = [[NIMNosLbsConfig alloc] init];
        
        
        [self readConfig];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNetChanged:)
                                                     name:NIMReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)queryLbs
{
    [self queryLbsForType:NIMLbsTypeLink];
    [self queryLbsForType:NIMLbsTypeNOS];
}

- (void)queryLbsForType:(NIMLbsType)type
{
    dispatch_block_t block = ^(){
        NIMLbsConfig *config = [self configByType:type];
        NIMLogApp(@"query lbs for %@",[config name]);
        if ([config isQuery])
        {
            return;
        }
        NIMLogApp(@"begin to query lbs %@",[config name]);
        [config setIsQuery:YES];
        [[config timer] stopTimer];
        NSString *urlString = [config lbsURL];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:30];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   NIMLogApp(@"query completed %@ error %@ for %@",response,connectionError,[config name]);
                                   
                                   [config setIsQuery:NO];
                                   [[config timer] stopTimer];
                                   [config setCachedLbs:nil];
                                   

                                   if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]])
                                   {
                                       NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                       if (status == 200 && data)
                                       {
                                           @synchronized(self)
                                           {
                                               NSDictionary *dict = [config parseData:data];
                                               if ([dict isKindOfClass:[NSDictionary class]])
                                               {
                                                   [self updateSwitcher:dict
                                                              forConfig:type];
                                                   [config setEverFetched:YES];
                                                   [config saveConfig:data];
                                               }
                                           }
                                       }
                                   }
                                   
                               }];
        
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

- (NSString *)nosURL
{
    NSString *nosURL = [self hostByType:NIMLbsTypeNOS];
    return nosURL;
}

- (NIMLinkAddress *)link
{
    NSString *host = [self hostByType:NIMLbsTypeLink];
    NIMLinkAddress *address = [[NIMLinkAddress alloc] init];
    NSArray *components = [host componentsSeparatedByString:@":"];
    address.address = [components firstObject];
    address.port = [[components lastObject] integerValue];
    return address;
}

- (NSString *)nosAccURL
{
    NSString *url = nil;
    @synchronized(self)
    {
        if (_nosDLAddress)
        {
            url = _nosDLAddress;
        }
        else
        {
            NIMServerSetting *setting = [[NIMSDK sharedSDK] setting];
            url = [setting nosAccAddress];
        }
    }
    return url;
}

- (void)reportError:(NIMLbsType)type
              fatal:(BOOL)fatal
{
    if (self.stopReportLink && type == NIMLbsTypeLink)
    {
        NIMLogApp(@"report %zd ignored",fatal);
        return;
    }
    
    @synchronized(self)
    {
        NIMHostSwitcher *switcher = [self switcherByType:type];
        [switcher reportError:fatal];
        [self checkSwitcher:switcher];
    }
}

- (NSString *)hostByType:(NIMLbsType)type
{
    @synchronized(self)
    {
        NIMHostSwitcher *switcher = [self switcherByType:type];
        NSString *host = [switcher currentHost];
        [self checkSwitcher:switcher];
        return host;
    }
}

- (void)onNetChanged:(NSNotification *)aNotification
{
    NIMLogApp(@"net changed, query lbs in 10 seconds");
    nim_main_async_safe(^{
        
        NSArray *configs = @[_nosConfig,_appConfig];
        for (NIMLbsConfig *config in configs)
        {
            [[config timer] startTimer:10
                              delegate:self
                               repeats:YES];
        }
    });
}

#pragma mark - get functions
- (NIMHostSwitcher *)switcherByType:(NIMLbsType)type
{
    NIMHostSwitcher *switcher = nil;
    switch (type) {
        case NIMLbsTypeLink:
            switcher = _appSwitcher;
            break;
        case NIMLbsTypeNOS:
            switcher = _nosSwitcher;
            break;
        default:
            assert(0);
            break;
    }
    return switcher;
}

- (NIMLbsConfig *)configByType:(NIMLbsType)type
{
    NIMLbsConfig *config = nil;
    switch (type) {
        case NIMLbsTypeLink:
            config = _appConfig;
            break;
        case NIMLbsTypeNOS:
            config = _nosConfig;
            break;
        default:
            assert(0);
            break;
    }
    return config;
}

#pragma mark - Timer Delegate
- (void)onNIMTimerFired:(NIMTimer *)timer
{
    if (timer == [_appConfig timer])
    {
        [self queryLbsForType:NIMLbsTypeLink];
    }
    else if (timer == [_nosConfig timer])
    {
        [self queryLbsForType:NIMLbsTypeNOS];
    }
}

#pragma makr - misc
- (void)checkSwitcher:(NIMHostSwitcher *)switcher
{
    NIMLbsType type = switcher.type;
    NIMLbsConfig *config = [self configByType:type];
    NSString *name = [config name];
    
    
    BOOL outOfRange = [switcher outOfRange];
    if (outOfRange)
    {
        [switcher resetIndex];
        NIMLogWar(@"reset host switcher %@",name);
    }
    
    if (outOfRange || ![config everFetched])
    {
        NIMLogApp(@"%@ out of range, query %@ lbs in 5 seconds %d",switcher,name,[config everFetched]);
        nim_main_async_safe(^{
            NIMTimer *timer = [config timer];
            if (![timer isScheduled])
            {
                [timer startTimer:5
                         delegate:self
                          repeats:NO];
            }
            else
            {
                NIMLogWar(@"time for %@ is scheduled",name);
            }
        });
    }
}



- (void)readConfig
{
    NSDictionary *app = [_appConfig readConfig];
    [self updateSwitcher:app
               forConfig:NIMLbsTypeLink];
    
    NSDictionary *nos = [_nosConfig readConfig];
    [self updateSwitcher:nos
               forConfig:NIMLbsTypeNOS];
}



- (void)updateSwitcher:(NSDictionary *)dict
             forConfig:(NIMLbsType)type
{
    NIMHostSwitcher *switcher = [self switcherByType:type];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        if (type == NIMLbsTypeLink)
        {
            NSArray *hosts = [dict nim_jsonStringArray:@"link"];
            [switcher updateHosts:hosts];
            NIMLogApp(@"%@",switcher);
            
            _nosDLAddress = [[dict nim_jsonStringArray:@"nosdls"] firstObject];
            NIMLogApp(@"nos dl address %@",_nosDLAddress);
        }
        else if (type == NIMLbsTypeNOS)
        {
            NSArray *hosts = [dict nim_jsonStringArray:@"upload"];
            [switcher updateHosts:hosts];
            NIMLogApp(@"%@",switcher);
        }
    }
}


@end
