//
//  NIMMessageObjectTest.m
//  NIMLib
//
//  Created by amao on 3/15/16.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NIMBaseTest.h"
#import "NIMSDK_Private.h"
#import "NIMMessage_Private.h"
#import "NIMImageObject_Private.h"
#import "NIMAudioObject_Private.h"
#import "NIMVideoObject_Private.h"
#import "NIMFileObject_Private.h"
#import "NIMTestMessageMaker.h"
#import "NIMNOSUtil.h"
#import "NIMPathManager.h"
#import "NIMTestMedialUtil.h"
#import "NSData+NIM.h"
#import "NIMUtil.h"
#import "NSString+NIM.h"


@interface NIMMessageObjectTest : NIMBaseTest

@end

@implementation NIMMessageObjectTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    
}


#pragma mark - 图片
- (void)testImageWithImage
{
    
    for (NSInteger i = 0; i < 3; i++) {
        
        UIImage *image = [NIMTestMedialUtil randomImage];

        
        for (NSInteger j = 0; j < 3; j++)
        {
            NIMImageObject *object = [[NIMImageObject alloc] initWithImage:image];
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NIMImageObject *imageObject = (NIMImageObject *)[message messageObject];
            
            
            NSString *filepath = [imageObject path];
            XCTAssertTrue([fileManager fileExistsAtPath:filepath]);
            
            
            NSString *thumbPath = [imageObject thumbPath];
            UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
            XCTAssertTrue([fileManager fileExistsAtPath:thumbPath]);
            XCTAssertNotNil(thumbImage);
            
            NSString *md5 = [NIMNOSUtil fileMD5:filepath];
            XCTAssertNotNil(md5);
            XCTAssertTrue([md5 isEqualToString:imageObject.md5]);
            
            CGSize size = image.size;
            XCTAssertFalse(CGSizeEqualToSize(size, CGSizeZero));
            XCTAssertTrue(CGSizeEqualToSize(size, imageObject.size));
            
            long long fileLength = [NIMNOSUtil fileSize:filepath];
            XCTAssertNotEqual(fileLength, 0);
            XCTAssertEqual(fileLength, imageObject.fileLength);
        }

    }
}

- (void)testImageWithFilepath
{
    for (NSInteger i = 0; i < 3; i++) {
        
        NSString *srcFilepath = [NIMTestMedialUtil randomImageWithPath];
        
        for (NSInteger j = 0; j < 3; j++)
        {
        
            NIMImageObject *object = [[NIMImageObject alloc] initWithFilepath:srcFilepath];
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NIMImageObject *imageObject = (NIMImageObject *)[message messageObject];
            
            
            NSString *dstFilepath = [imageObject path];
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *thumbPath = [imageObject thumbPath];
            UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
            XCTAssertTrue([fileManager fileExistsAtPath:thumbPath]);
            XCTAssertNotNil(thumbImage);
            
            
            NSString *srcFileMD5 = [NIMNOSUtil fileMD5:srcFilepath];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *imageMD5 = imageObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(imageMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:imageMD5]);
            
            
            UIImage *srcImage = [UIImage imageWithContentsOfFile:srcFilepath];
            UIImage *dstImage = [UIImage imageWithContentsOfFile:dstFilepath];
            CGSize srcImageSize = srcImage.size;
            CGSize dstImageSize = dstImage.size;
            
            XCTAssertFalse(CGSizeEqualToSize(srcImageSize, CGSizeZero));
            XCTAssertTrue(CGSizeEqualToSize(srcImageSize, dstImageSize));
            XCTAssertTrue(CGSizeEqualToSize(srcImageSize, imageObject.size));
            
            long long srcFileLength = [NIMNOSUtil fileSize:srcFilepath];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, imageObject.fileLength);
            
        }
        
    }
}


- (void)testImageWithData
{
    NSArray *exts = @[@"jpg",@"raw"];
    
    for (NSInteger i = 0; i < 3; i++) {
        
        NSData *imageData = [NIMTestMedialUtil randomImageWithData];
        NSString *imageExt = i < [exts count] ? [exts objectAtIndex:i] : nil;
        
        for (NSInteger j = 0; j < 3; j++)
        {
            NIMImageObject *object = [[NIMImageObject alloc] initWithData:imageData
                                                                extension:imageExt];
            
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NIMImageObject *imageObject = (NIMImageObject *)[message messageObject];
            
            
            NSString *dstFilepath = [imageObject path];
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *thumbPath = [imageObject thumbPath];
            UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
            XCTAssertTrue([fileManager fileExistsAtPath:thumbPath]);
            XCTAssertNotNil(thumbImage);
            
            
            NSString *srcFileMD5 = [imageData nim_md5];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *imageMD5 = imageObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(imageMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:imageMD5]);
            
            
            UIImage *srcImage = [UIImage imageWithData:imageData];
            UIImage *dstImage = [UIImage imageWithContentsOfFile:dstFilepath];
            CGSize srcImageSize = srcImage.size;
            CGSize dstImageSize = dstImage.size;
            
            XCTAssertFalse(CGSizeEqualToSize(srcImageSize, CGSizeZero));
            XCTAssertTrue(CGSizeEqualToSize(srcImageSize, dstImageSize));
            XCTAssertTrue(CGSizeEqualToSize(srcImageSize, imageObject.size));
            
            long long srcFileLength = [imageData length];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, imageObject.fileLength);
            
        }
        
    }
}

#pragma mark - 音频
- (void)testAudioWithPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSInteger i = 0; i < 3; i ++)
    {
        
        NSString *srcFilepath = [NIMTestMedialUtil randomAudioWithPath];
        XCTAssertNotNil(srcFilepath);
        XCTAssertTrue([fileManager fileExistsAtPath:srcFilepath]);
        NSInteger duration = i % 2 ? 200 : 0;
        NSInteger srcDuration = duration ? : [NIMUtil mediaLengthForFile:srcFilepath];
        
        
        for (NSInteger j = 0; j < 5; j++)
        {
            NIMAudioObject *object = [[NIMAudioObject alloc] initWithSourcePath:srcFilepath];
            object.duration = duration;
            
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NIMAudioObject *audioObject = (NIMAudioObject *)message.messageObject;
            
            NSString *dstFilepath = audioObject.path;
            XCTAssertNotNil(dstFilepath);
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *srcFileMD5 = [NIMNOSUtil fileMD5:srcFilepath];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *fileMD5 = audioObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(fileMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:fileMD5]);
            
            
            long long srcFileLength = [NIMNOSUtil fileSize:srcFilepath];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, audioObject.fileLength);
            
            
            NSString *srcExt = [srcFilepath pathExtension];
            NSString *dstExt = [dstFilepath pathExtension];
            NSString *fileExt = [audioObject.fileName pathExtension];
            
            XCTAssertNotNil(srcExt);
            XCTAssertNotNil(dstExt);
            XCTAssertNotNil(fileExt);
            XCTAssertTrue([srcExt isEqualToString:dstExt]);
            XCTAssertTrue([srcExt isEqualToString:fileExt]);
            
            NSInteger dstDuration = audioObject.duration;
            XCTAssertNotEqual(srcDuration, 0);
            XCTAssertEqual(srcDuration, dstDuration);

            
        }
    }
}


- (void)testAudioWithData
{
    NSArray *exts = @[@"aac"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    for (NSInteger i = 0; i < 3; i ++)
    {
        NSData *audioData = [NIMTestMedialUtil randomAudioWithData];
        NSString *ext = i < [exts count] ? [exts objectAtIndex:i] :nil;
        NSInteger duration = i % 2 ? 200 : 0;
        
        XCTAssertNotNil(audioData);
        
        NSString *tmpName = [[NIMUtil uuid] nim_stringByAppendExt:ext];
        NSString *tmpFilepath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpName];
        [audioData writeToFile:tmpFilepath atomically:YES];
        NSInteger srcDuration = duration ? : [NIMUtil mediaLengthForFile:tmpFilepath];
        
        for (NSInteger j = 0; j < 5; j++)
        {
            NIMAudioObject *object = [[NIMAudioObject alloc] initWithData:audioData
                                                                extension:ext];
            object.duration = duration;
            
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NIMAudioObject *audioObject = (NIMAudioObject *)message.messageObject;
            
            NSString *dstFilepath = audioObject.path;
            XCTAssertNotNil(dstFilepath);
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *srcFileMD5 = [audioData nim_md5];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *fileMD5 = audioObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(fileMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:fileMD5]);
            
            
            long long srcFileLength = [audioData length];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, audioObject.fileLength);
            
            
            NSString *srcExt = ext;
            NSString *dstExt = [dstFilepath pathExtension];
            NSString *fileExt = [audioObject.fileName pathExtension];
            
            
            NSInteger dstDuration = audioObject.duration;
    
            if (ext)
            {
                XCTAssertNotNil(srcExt);
                XCTAssertNotNil(dstExt);
                XCTAssertNotNil(fileExt);
                XCTAssertTrue([srcExt isEqualToString:dstExt]);
                XCTAssertTrue([srcExt isEqualToString:fileExt]);
                
                
                XCTAssertNotEqual(srcDuration, 0);
                XCTAssertEqual(srcDuration, dstDuration);
            }
            else
            {
                XCTAssertTrue([srcExt length] == 0);
                XCTAssertTrue([dstExt length] == 0);
                XCTAssertTrue([fileExt length] == 0);
                
                if (duration)
                {
                    XCTAssertEqual(srcDuration, duration);
                    XCTAssertEqual(srcDuration, dstDuration);
                }
                else
                {
                    XCTAssertEqual(srcDuration, 0);
                    XCTAssertEqual(duration, dstDuration);
                }
                
            }
            
            

            
            
        }
    }
}


#pragma mark - 视频
- (void)testVideoWithPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    for (NSInteger i = 0; i < 3; i ++)
    {
        
        NSString *srcFilepath = [NIMTestMedialUtil randomVideoWithPath];
        XCTAssertNotNil(srcFilepath);
        XCTAssertTrue([fileManager fileExistsAtPath:srcFilepath]);
        NSInteger duration = i % 2 ? 200 : 0;
        NSInteger srcDuration = duration ? : [NIMUtil mediaLengthForFile:srcFilepath];
        
        
        for (NSInteger j = 0; j < 5; j++)
        {
            NIMVideoObject *object = [[NIMVideoObject alloc] initWithSourcePath:srcFilepath];
            object.duration = duration;
            
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NIMVideoObject *videoObject = (NIMVideoObject *)message.messageObject;
            
            NSString *dstFilepath = videoObject.path;
            XCTAssertNotNil(dstFilepath);
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *srcFileMD5 = [NIMNOSUtil fileMD5:srcFilepath];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *fileMD5 = videoObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(fileMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:fileMD5]);
            
            
            long long srcFileLength = [NIMNOSUtil fileSize:srcFilepath];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, videoObject.fileLength);
            
            
            NSString *srcExt = [srcFilepath pathExtension];
            NSString *dstExt = [dstFilepath pathExtension];
            NSString *fileExt = [videoObject.fileName pathExtension];
            
            XCTAssertNotNil(srcExt);
            XCTAssertNotNil(dstExt);
            XCTAssertNotNil(fileExt);
            XCTAssertTrue([srcExt isEqualToString:dstExt]);
            XCTAssertTrue([srcExt isEqualToString:fileExt]);
            
            NSInteger dstDuration = videoObject.duration;
            XCTAssertNotEqual(srcDuration, 0);
            XCTAssertEqual(srcDuration, dstDuration);
            
            NSString *thumbPath = videoObject.coverPath;
            UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
            XCTAssertNotNil(thumbImage);
            XCTAssertTrue(CGSizeEqualToSize(thumbImage.size, videoObject.coverSize));
            
            
            
        }
    }
}

- (void)testVideoWithData
{
    NSArray *exts = @[@"mp4"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSInteger i = 0; i < 3; i ++)
    {
        NSString *ext = i < [exts count] ? [exts objectAtIndex:i] : nil;
        NSData *videoData = [NIMTestMedialUtil randomVideoWithData];
        NSInteger duration = i % 2 ? 200 : 0;
        NSString *tmpName = [[NIMUtil uuid] nim_stringByAppendExt:ext];
        NSString *tmpFilepath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpName];
        [videoData writeToFile:tmpFilepath atomically:YES];
        NSInteger srcDuration = duration ? : [NIMUtil mediaLengthForFile:tmpFilepath];
        

        
        
        for (NSInteger j = 0; j < 5; j++)
        {
            NIMVideoObject *object = [[NIMVideoObject alloc] initWithData:videoData
                                                                extension:ext];
            object.duration = duration;
            
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NIMVideoObject *videoObject = (NIMVideoObject *)message.messageObject;
            
            NSString *dstFilepath = videoObject.path;
            XCTAssertNotNil(dstFilepath);
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *srcFileMD5 = [videoData nim_md5];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *fileMD5 = videoObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(fileMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:fileMD5]);
            
            
            long long srcFileLength = [videoData length];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, videoObject.fileLength);
            
            
            NSString *srcExt = ext;
            NSString *dstExt = [dstFilepath pathExtension];
            NSString *fileExt = [videoObject.fileName pathExtension];
            
            NSInteger dstDuration = videoObject.duration;
            if (ext)
            {
                XCTAssertNotNil(srcExt);
                XCTAssertNotNil(dstExt);
                XCTAssertNotNil(fileExt);
                XCTAssertTrue([srcExt isEqualToString:dstExt]);
                XCTAssertTrue([srcExt isEqualToString:fileExt]);
                
                XCTAssertNotEqual(srcDuration, 0);
                XCTAssertEqual(srcDuration, dstDuration);
                
                
                NSString *thumbPath = videoObject.coverPath;
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                XCTAssertNotNil(thumbImage);
                XCTAssertTrue(CGSizeEqualToSize(thumbImage.size, videoObject.coverSize));
            }
            else
            {
                XCTAssertTrue([srcExt length] == 0);
                XCTAssertTrue([dstExt length] == 0);
                XCTAssertTrue([fileExt length] == 0);
                
                if (duration)
                {
                    XCTAssertEqual(srcDuration, duration);
                    XCTAssertEqual(srcDuration, dstDuration);
                }
                else
                {
                    XCTAssertEqual(srcDuration, 0);
                    XCTAssertEqual(duration, dstDuration);
                }
                
                NSString *thumbPath = videoObject.coverPath;
                UIImage *thumbImage = [UIImage imageWithContentsOfFile:thumbPath];
                XCTAssertNil(thumbImage);
            }
            
        }
    }
}



#pragma mark - 文件

- (void)testFileWithPath
{
    for (NSInteger i = 0; i < 3; i ++)
    {
        NSString *srcFilepath = [NIMTestMedialUtil randomFileWithPath];
        
        for (NSInteger j = 0; j < 3; j++)
        {
            NIMFileObject *object = [[NIMFileObject alloc] initWithSourcePath:srcFilepath];
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NIMFileObject *fileObject = (NIMFileObject *)[message messageObject];
            
            NSString *dstFilepath = fileObject.path;
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *srcFileMD5 = [NIMNOSUtil fileMD5:srcFilepath];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *fileMD5 = fileObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(fileMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:fileMD5]);
            
            
            long long srcFileLength = [NIMNOSUtil fileSize:srcFilepath];
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, fileObject.fileLength);
            
            
            NSString *srcExt = [srcFilepath pathExtension];
            NSString *dstExt = [dstFilepath pathExtension];
            NSString *fileExt = fileObject.ext;

            XCTAssertNotNil(srcExt);
            XCTAssertNotNil(dstExt);
            XCTAssertNotNil(fileExt);
            XCTAssertTrue([srcExt isEqualToString:dstExt]);
            XCTAssertTrue([srcExt isEqualToString:fileExt]);
            
            
        }
    }
}


- (void)testFileWithData
{
    NSArray *exts = @[@"jpg",@"png"];
    
    for (NSInteger i = 0; i < 3; i ++)
    {
        NSData *srcData = [NIMTestMedialUtil randomFileWithData];
        NSString *srcExt = i < [exts count] ? [exts objectAtIndex:i] : nil;
        
        for (NSInteger j = 0; j < 5; j++)
        {
            NIMFileObject *object = [[NIMFileObject alloc] initWithData:srcData
                                                              extension:srcExt];
            NIMMessage *message = [[NIMMessage alloc] init];
            message.messageObject = object;
            
            NSError *error = [message prepareForSend];
            XCTAssertNil(error);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NIMFileObject *fileObject = (NIMFileObject *)[message messageObject];
            
            NSString *dstFilepath = fileObject.path;
            XCTAssertTrue([fileManager fileExistsAtPath:dstFilepath]);
            
            NSString *srcFileMD5 = [srcData nim_md5];
            NSString *dstFileMD5 = [NIMNOSUtil fileMD5:dstFilepath];
            NSString *fileMD5 = fileObject.md5;
            
            XCTAssertNotNil(srcFileMD5);
            XCTAssertNotNil(dstFileMD5);
            XCTAssertNotNil(fileMD5);
            XCTAssertTrue([srcFileMD5 isEqualToString:dstFileMD5]);
            XCTAssertTrue([srcFileMD5 isEqualToString:fileMD5]);
            
            
            long long srcFileLength = (long long)srcData.length;
            long long dstFileLength = [NIMNOSUtil fileSize:dstFilepath];
            XCTAssertNotEqual(srcFileLength, 0);
            XCTAssertEqual(srcFileLength, dstFileLength);
            XCTAssertEqual(srcFileLength, fileObject.fileLength);
            
            

            NSString *dstExt = [dstFilepath pathExtension];
            NSString *fileExt = fileObject.ext;
            
            if (srcExt)
            {
                XCTAssertNotNil(srcExt);
                XCTAssertNotNil(dstExt);
                XCTAssertNotNil(fileExt);
                XCTAssertTrue([srcExt isEqualToString:dstExt]);
                XCTAssertTrue([srcExt isEqualToString:fileExt]);
            }
            else
            {
                XCTAssertTrue([srcExt length] == 0);
                XCTAssertTrue([dstExt length] == 0);
                XCTAssertTrue([fileExt length] == 0);
            }
            
            
            
            
        }
    }
}




@end
