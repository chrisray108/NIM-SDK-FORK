//
//  NIMMediaManagerTest.m
//  NIMLib
//
//  Created by amao on 3/31/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMFeedbackCenter.h"
#import "NIMTestMedialUtil.h"
#import "NIMUtil.h"
#import "NIMNOSUtil.h"

@interface NIMMediaManagerTest : NIMBaseTest

@end

@implementation NIMMediaManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAudioTrans
{
    NSString *filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"audio" ofType:@"aac"];
    __block NSString *url = nil;
    [[[NIMSDK sharedSDK] resourceManager] upload:filepath
                                        progress:nil
                                      completion:^(NSString *urlString, NSError *error) {
                                          url = urlString;
                                          XCTAssertNil(error);
                                          XCTAssertTrue([urlString length] > 0);
                                          NIM_TEST_NOTIFY;
                                      }];
    NIM_TEST_WAIT;
    
    
    
    NIMAudioToTextOption *option = [[NIMAudioToTextOption alloc] init];
    option.url = url;
    option.filepath = filepath;
    [[[NIMSDK sharedSDK] mediaManager] transAudioToText:option
                                                 result:^(NSError *error, NSString *text) {
                                                     XCTAssertNil(error);
                                                     XCTAssertTrue([text length] > 0);
                                                     XCTAssertTrue([text isEqualToString:@"我以为开始测试1234567。"]);
                                                     NIM_TEST_NOTIFY;
                                                 }];
    NIM_TEST_WAIT;
}

- (void)testUploadAndDownload
{
    NSString *filepath = [NIMTestMedialUtil randomImageWithPath];
    __block NSString *resultURL = nil;
    
    [[[NIMSDK sharedSDK] resourceManager] upload:filepath
                                        progress:^(CGFloat progress) {
                                            NSLog(@"upload %@ progress %lf",filepath,progress);
                                        } completion:^(NSString *urlString, NSError *error) {
                                            resultURL = urlString;
                                            XCTAssertNil(error);
                                            XCTAssertTrue([urlString length] > 0);
                                            NIM_TEST_NOTIFY;
                                        }];
    NIM_TEST_WAIT
    
    NSString *downloadFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NIMUtil uuid]];
    [[[NIMSDK sharedSDK] resourceManager] download:resultURL
                                          filepath:downloadFile
                                          progress:^(CGFloat progress) {
                                              NSLog(@"download %@ progress %lf",downloadFile,progress);
                                          } completion:^(NSError *error) {
                                              XCTAssertNil(error);
                                              NIM_TEST_NOTIFY;
                                          }];
    
    NIM_TEST_WAIT;
    
    NSString *srcMD5 = [NIMNOSUtil fileMD5:filepath];
    NSString *dstMD5 = [NIMNOSUtil fileMD5:downloadFile];
    XCTAssertNotNil(srcMD5);
    XCTAssertNotNil(dstMD5);
    XCTAssertTrue([srcMD5 isEqualToString:dstMD5]);
    
}

- (void)testFeedback
{
    //只是简单跑一次,只要没有崩溃即可，不判断成功
    [[NIMFeedbackCenter sharedCenter] feedback];
}
@end
