//
//  core_checker.cpp
//  NIM
//
//  Created by amao on 3/11/14.
//  Copyright (c) 2014 Netease. All rights reserved.
//

#include "core_checker.h"
#include "assert.h"
#include "document_defs.h"

namespace nimbiz
{

void CoreChecker::CheckDocumentEntries()
{
    //以下几个Document的Entry和timetag相关，所以不能直接改名
    //如果要像其他与timetag无关的Entry一样改名，需要修改Document的文件路径，整个文件重新载入
    
    bool valid = DN_FRIENDS     == "friends" &&
                 DN_RELATION    == "relation" &&
                 DN_USERS       == "users" &&
                 DN_SYNC        == "sync" &&
                 DN_TINFO       == "tinfo" &&
                 DN_TLIST       == "tlist";
    
    assert(valid);
    
}

}