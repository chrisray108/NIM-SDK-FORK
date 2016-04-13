//
//  NIMHostSwitcher.m
//  NIMLib
//
//  Created by amao on 4/13/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMHostSwitcher.h"




@implementation NIMHostSwitcher


+ (NIMHostSwitcher *)switcher:(NIMLbsType)type
                  defaultHost:(NSString *)defaultHost
                  maxErrTimes:(NSInteger)times
{
    NIMHostSwitcher *switcher = [[NIMHostSwitcher alloc] init];
    switcher.type = type;
    switcher.defaultHost = defaultHost;
    switcher.maxErrTimes = times;
    return switcher;
}

- (NSString *)currentHost
{
    NSString *host = nil;
    if (_index >= 0 && _index < [_hosts count])
    {
        host = [_hosts objectAtIndex:_index];
    }
    return host ? : _defaultHost;
}

- (BOOL)outOfRange
{
    return _index >= [_hosts count];
}

- (void)resetIndex
{
    _index = 0;
    _errTimes = 0;
}

- (void)updateHosts:(NSArray *)hosts
{
    if (hosts)
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:hosts];
        [array addObject:_defaultHost];
        _hosts = array;
        _index = 0;
        _errTimes = 0;
    }
    else
    {
        NIMAssert();
    }
}

- (NSString *)description
{
    NSString *hosts = [_hosts componentsJoinedByString:@" "];
    NSString *type = _type == NIMLbsTypeLink ? @"link" : @"nos";
    return [NSString stringWithFormat:@"{\ntype :%@\nhosts: %@ \ndefault host:%@\nindex: %zd\n}",type,hosts,_defaultHost,_index];
}

- (void)reportError:(BOOL)fatal
{
    NIMLogApp(@"report fatal:%d  errTimes %zd  maxErrTimes %zd \n to %@",fatal,_errTimes,_maxErrTimes,self);
    if (fatal)
    {
        _index ++;
    }
    else
    {
        _errTimes++;
        if (_errTimes >= _maxErrTimes)
        {
            _errTimes = 0;
            _index++;
        }
    }
    
}
@end