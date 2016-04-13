//
//  NIMAudioTrans.m
//  NIMLib
//
//  Created by amao on 7/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NIMAudioTrans.h"
#import "NIMDispatch.h"
#import "NIMGlobalDefs.h"
#import "misc_protocol.h"
#import "bind.h"
#import "NIMUtil.h"
#import "NIMNOSUtil.h"
#import "NIMCallbackManager.h"
#import "NIMAudioToTextOptionValidator.h"



@interface NIMAudioToTextCallback : NSObject<NIMCallback>
@property (nonatomic,copy)  NIMAudioToTextBlock block;
@end


@implementation NIMAudioToTextCallback

- (void)convertParam:(nimbiz::IAsynCallbackParam *)param
            toResult:(NIMCallbackResult *)result
{
    nimbiz::CBTransAudioParam *audioParam = dynamic_cast<nimbiz::CBTransAudioParam *>(param);
    if (audioParam)
    {
        result.error = NIMRemoteError(audioParam->code_);
        result.resultObject = result.error ? nil : NSUTF8(audioParam->text_);
    }
}


- (void)run:(NIMCallbackResult *)result
{
    if (_block) {
        _block(result.error,(NSString *)result.resultObject);
    }
}


@end


@implementation NIMAudioToTextOption
@end

@interface NIMAudioTrans ()
@end

@implementation NIMAudioTrans

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)trans:(NIMAudioToTextOption *)option
   completion:(NIMAudioToTextBlock)block
{
    if (![[NIMAudioToTextOptionValidator validator:option] isValid]) {
        if (block) {
            nim_main_async_safe(^{
                block(NIMLocalError(NIMLocalErrorCodeInvalidParam),nil);
            });
            
        }
        return;
    }
    
    dispatch_block_t mainBlock = ^(){
        
        nimbiz::Property info;
        [self fillProperty:info
                  byOption:option];
        
        nimbiz::IMiscService *service = (nimbiz::IMiscService *)GetServiceFromCore(nimbiz::SVID_NIM_MISC);
        if (service)
        {
            NSInteger taskID = (NSInteger)service->Invoke_TransAudio(info, nimbiz::GetNIMCallback());
            
            NIMAudioToTextCallback *param = [NIMAudioToTextCallback new];
            param.block = block;
            
            [[NIMCallbackManager sharedManager] setCallback:param
                                                    forTask:taskID];
        }
        
    };
    nim_main_async_safe(mainBlock);
    
}

- (void)fillProperty:(nimbiz::Property &)property
            byOption:(NIMAudioToTextOption *)option
{
    NSString *filepath  = option.filepath;
    NSString *mimeType  = [NIMNOSUtil mimeType:filepath];
    NSInteger duration  = [NIMUtil mediaLengthForFile:filepath];
    NSInteger sampleRate= [NIMUtil sampleRateForFile:filepath];
    
    
    property.put_string(nimbiz::NIMAudioToTextTagMime, UTF8(mimeType));
    property.put_int32(nimbiz::NIMAudioToTextTagSample, (int32_t)sampleRate);
    property.put_string(nimbiz::NIMAudioToTextTagURL, UTF8(option.url));
    property.put_int32(nimbiz::NIMAudioToTextTagDuration, (int32_t)duration);
    
    NIMLogApp(@"audio to text %@ mimetype %@ sample rate %zd duration %zd",
              option.url,mimeType,sampleRate,duration);
}


@end

