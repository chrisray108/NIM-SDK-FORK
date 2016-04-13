//
//  rsa_util.m
//  NIM
//
//  Created by amao on 13-9-1.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "rsa_util.h"
#import "base/encrypt/encrypt_impl.h"
#import "RSAConfig.h"
#import "NIMSDK_Private.h"
#import "NIMSDKConfig_Private.h"

#pragma mark - 辅助方法

namespace nimbiz {

UTF8String  NIMGetInternalModule()
{
    @autoreleasepool
    {
        return UTF8([[[NIMSDK sharedSDK] setting] module]);
    }
}

int NIMGetInternalVersion()
{
    @autoreleasepool
    {
        return (int)([[[NIMSDK sharedSDK] setting] version]);
    }
}

#pragma mark - Public API



void    SaveRSAConfig(const UTF8String &hex_module,int version)
{
    @autoreleasepool
    {
        if (hex_module.size())
        {
            NIMRSAConfig *config = [NIMRSAConfig config:[NSString stringWithUTF8String:hex_module.c_str()]
                                                version:version];
            
            if (![config save])
            {
                NIMLogErr(@"Save RSA Config Failed");
            }
        }
        else
        {
            NIMLogErr(@"Empty Hex Module");
        }
    }
}


void    ReadRSAConfig(UTF8String &hex_module,int &version)
{
    @autoreleasepool
    {
        NIMRSAConfig *config = [NIMRSAConfig readLocalConfig];
        if ([config isValidConfig] &&
            [config version] > NIMGetInternalVersion())
        {
            hex_module  = [[config module] UTF8String];
            version     = (int)[config version];
        }
        else
        {
            hex_module  = NIMGetInternalModule();
            version     = NIMGetInternalVersion();
        }
    }
}


void    RSAEncrypt(const UTF8String &raw_content,
                   const UTF8String &hex_module,
                   UTF8String &encrypted_data)
{
    encrypted_data.clear();
    
    
    BIGNUM *bnn, *bne;
    bnn = BN_new();
    bne = BN_new();
    
    BN_hex2bn(&bnn, hex_module.c_str());
    BN_set_word(bne, RSA_F4);
    
    RSA *pRSA = RSA_new();
    pRSA->n = bnn;
    pRSA->e = bne;
    
    
    size_t ssize = raw_content.size();
    
    unsigned char buf[256];
    int           ret = -1;
    try
    {
        
        uint32_t block_size = RSA_size(pRSA) - 11;
        
        uint32_t nBlock    = (uint32_t)( ssize + block_size - 1) / block_size;
        const unsigned char * psrc = (const unsigned char *)raw_content.c_str();
        for (uint32_t i = 0; i < nBlock; i++)
        {
            uint32_t sz = block_size;
            
            if ((i+1) == nBlock && (ssize%block_size!=0))
            {
                sz = ssize % block_size;
            }
            ret = RSA_public_encrypt(sz, psrc ,buf, pRSA, RSA_PKCS1_PADDING);
            if (ret > 0)
            {
                encrypted_data.append((const char *)buf, ret);
                psrc += sz;
            }
            else
                break;
        }
    }
    catch(...)
    {
    }
    
    pRSA->n = 0;
    pRSA->e = 0;
    BN_free(bnn);
    BN_free(bne);
    RSA_free(pRSA);
}

}