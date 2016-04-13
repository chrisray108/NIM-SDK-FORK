//
//  rsa_util.h
//  NIM
//
//  Created by amao on 13-9-1.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#ifndef BIZ_CORE_RSA_UTIL_H_
#define BIZ_CORE_RSA_UTIL_H_

#include "biz/protocol/property.h"

namespace nimbiz {

void    SaveRSAConfig(const UTF8String &hex_module,int version);
void    ReadRSAConfig(UTF8String &hex_module,int &version);
void    RSAEncrypt(const UTF8String &raw_content,
                   const UTF8String &hex_module,
                   UTF8String &encrypted_data);
}
#endif