//
//  NIMTestServerAPI.m
//  NIMLib
//
//  Created by amao on 1/26/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "NIMTestServerAPI.h"
#import "NIMTestConfig.h"
#import "NIMTestServerAPIUtil.h"

@implementation NIMTestServerAPI

+ (void)post:(id<NIMTestServerRequest>)request
  completion:(NIMTestServerBlock)completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[[NIMTestConfig sharedConfig] webServer],[request name]];
    NSURL *url =  [NSURL URLWithString:urlString];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:0
                                                            timeoutInterval:30.0];
    [httpRequest setHTTPMethod:@"post"];
    NSDictionary *headers = [NIMTestServerAPIUtil serverRequestHeaders];
    for (NSString *key in headers.allKeys)
    {
        [httpRequest addValue:headers[key] forHTTPHeaderField:key];
    }
    [httpRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    NSDictionary *body = [request dict];
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *key in body.allKeys)
    {
        [items addObject:[NSString stringWithFormat:@"%@=%@",key,body[key]]];
    }
    NSString *postBody = [items componentsJoinedByString:@"&"];
    [httpRequest setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:httpRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               NSError *error = [NSError errorWithDomain:@"default"
                                                                    code:0
                                                                userInfo:nil];
                               NSInteger statusCode = [response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)response statusCode] : 0;
                               NSLog(@"http post result %zd",statusCode);
                               NSAssert(statusCode == 200,@"invalid code");
                               
                               id resultObject = nil;
                               if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]] &&
                                   [(NSHTTPURLResponse *)response statusCode] == 200)
                               {
                                   if (data)
                                   {
                                       NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:0
                                                                                              error:nil];
                                       if ([dict isKindOfClass:[NSDictionary class]])
                                       {
                                           resultObject = dict;
                                           error = nil;
                                       }
                                   }
                               }
                               if (completion) {
                                   completion(error,resultObject);
                               }
                           }];
}

@end
