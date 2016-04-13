// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/9
//
// Define property

#ifndef BIZ_PROTOCOL_PROPERTY_H_
#define BIZ_PROTOCOL_PROPERTY_H_

#include <map>
#include <string>
#include <stdio.h>
#include <stdlib.h>

#include "base/base_types.h"
#include "base/macros.h"
#include "base/memory/packet.h"
#include "base/util/string_util.h"
#include "protocol.h"

namespace nimbiz
{

typedef std::map<uint32_t, ByteBuffer> property_type;

struct Property : public nbase::Marshallable
{
    property_type props;
    
    ByteBuffer get(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
            return ByteBuffer();
        
        return it->second;
    }
    
    void put(uint32_t tag, const ByteBuffer &v)
    {
        props[tag] = v;
    }
    
    UTF8String get_string(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
            return ("");
        
        return it->second;
    }
    
    void put_string(uint32_t tag, const UTF8String &string)
    {
        props[tag] = string;
    }

    int32_t get_int32(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
        {
            return 0;
        }
        
        int32_t value = atoi(it->second.c_str());
        return value;
    }

    void put_int32(uint32_t tag, int32_t value)
    {
        nbase::UTF8Char str[16];
        memset(str, 0, 16);
        sprintf(str, INT32_FORMAT, value);        
        ByteBuffer buff = str;
        props[tag] = buff;
    }

    uint8_t get_uint8(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
        {
            return 0;
        }
        
        uint8_t value = atoi(it->second.c_str());
        return value;
    }
    
    void put_uint8(uint32_t tag, uint8_t value)
    {
        nbase::UTF8Char str[16];
        memset(str, 0, 16);
        sprintf(str, UINT8_FORMAT, value);        
        ByteBuffer buff = str;
        props[tag] = buff;
    }
    
    uint16_t get_uint16(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
        {
            return 0;
        }
        
        uint16_t value = atoi(it->second.c_str());
        return value;
    }
    
    void put_uint16(uint32_t tag, uint16_t value)
    {
        nbase::UTF8Char str[16];
        memset(str, 0, 16);
        sprintf(str, UINT16_FORMAT, value);        
        ByteBuffer buff = str;
        props[tag] = buff;
    }
       
    uint32_t get_uint32(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
        {
            return 0;
        }
        
        uint32_t value = (uint32_t)atol(it->second.c_str());
        return value;
    }
    
    void put_uint32(uint32_t tag, uint32_t value)
    {
        nbase::UTF8Char str[16];
        memset(str, 0, 16);
        sprintf(str, UINT32_FORMAT, value);        
        ByteBuffer buff = str;
        props[tag] = buff;
    }

    uint64_t get_uint64(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
        {
            return 0;
        }
        
        uint64_t value = atoll(it->second.c_str());
        return value;
    }
    
    void put_uint64(uint32_t tag, uint64_t value)
    {
        nbase::UTF8Char str[32];
        memset(str, 0, 32);
        sprintf(str, UINT64_FORMAT, value);
        ByteBuffer buff = str;
        props[tag] = buff;
    }

    bool has_tag(uint32_t tag) const
    {
        property_type::const_iterator it = props.find(tag);
        if(it == props.end())
        {
            return false;
        }
        return true;
    }
    
    virtual void update(const property_type &newprops)
    {
        property_type::const_iterator it;
        for (it = newprops.begin(); it != newprops.end(); it++)
        {
            props[it->first] = it->second;
        }
        
    }
    
    // 去掉在props2中已有，并且值是一样的tag
    virtual void diff(const Property& props2)
    {
        for(property_type::const_iterator it = props2.props.begin(); it != props2.props.end(); ++it)
        {
            uint32_t tag = it->first;
            ByteBuffer value = it->second;
            
            if(props.find(tag) != props.end() && get(tag) == value)
            {
                props.erase(props.find(tag));
            }
        }
    }
    
    virtual void marshal(nbase::Pack &p) const;
    virtual void unmarshal(const nbase::Unpack &up);
};

inline void Property::marshal(nbase::Pack &p) const
{
    p.push_len((uint32_t)props.size());
    
    for (property_type::const_iterator i = props.begin(); i != props.end(); ++i)
    {
        p.push_len(i->first);
        p << i->second;
    }
}

inline void Property::unmarshal(const nbase::Unpack &up)
{
    for (uint32_t count = up.pop_len(); count > 0; --count)
    {
        uint32_t    tag;
        ByteBuffer  buff;
        
        tag = up.pop_len();
        up >> buff;
        props[tag] = buff;
    }     
}



typedef std::map<UTF8String, Property> map2props_t;

struct MapProperty : public nbase::Marshallable
{
    map2props_t mapp;
    
    Property get(const UTF8String &key) const
    {
        map2props_t::const_iterator it = mapp.find(key);
        if(it == mapp.end())
            return Property();
        
        return it->second;
    }
    
    void put(const UTF8String &key, const Property &props)
    {
        mapp[key] = props;
    }
    
    virtual void marshal(nbase::Pack &p) const;
    virtual void unmarshal(const nbase::Unpack &up);
};

inline void MapProperty::marshal(nbase::Pack & p) const
{
    p.push_uint32((uint32_t)mapp.size());
    
    for (map2props_t::const_iterator i = mapp.begin(); i != mapp.end(); ++i)
    {
        p << i->first;
        p << i->second;
    }
}

inline void MapProperty::unmarshal(const nbase::Unpack &up)
{
    for (uint32_t count = up.pop_uint32(); count > 0; --count)
    {
        UTF8String key;
        Property   prop;
        
        up >> key;
        prop.unmarshal(up);
        mapp[key] = prop;
    }
}




namespace property
{
    
    /////////////////////////////////////////////////////////////////////
    inline void swap(Property &a, Property &b)
    {  
        a.props.swap(b.props); 
    }
    
    // 没有找到返回空串
    inline ByteBuffer get(const Property &a, uint32_t tag, const ByteBuffer &_def)
    {
        property_type::const_iterator i = a.props.find(tag);
        return (i != a.props.end()) ? i->second : _def;
    }
    
    inline ByteBuffer get(const Property &a, uint32_t tag)
    {
        return get(a, tag, ByteBuffer());
    }
    
    inline const ByteBuffer* find(const Property & a, uint32_t tag)
    {
        property_type::const_iterator i = a.props.find(tag);
        return (i != a.props.end()) ? &(i->second) : NULL;
    }
    
    /////////////////////////////////////////////////////////////////////
    // translate
    inline int get_int32(const Property & a, uint32_t tag, int _default = 0)
    {
        if (const ByteBuffer *val = find(a, tag))
        {
            int32_t value = *((int32_t *)(&(*val)[0]));
            return value;
        }
        return _default;
    }
    
    inline void set_int32(Property & a, uint32_t tag, int32_t value)
    {
        ByteBuffer buff;
        buff.append(reinterpret_cast<const char *>(&value), 4u);
        a.props[tag] = buff;
    }
    
    inline void copyif(Property &a, const Property &b, uint32_t tag)
    {
        if (const ByteBuffer *val = find(b, tag))
            a.props[tag] = &(*val)[0];
    }
    
    //////////////////////////////////////////////////////////////////
    //
    // 修改属性(不存在就添加)
    // 修改检测: 返回true 表示有改变
    // 参数apply 表示是否真的修改，或者只是检测
    inline bool replace(property_type &a,
                        const property_type::value_type &value, bool apply = true)
    {
        std::pair<property_type::iterator, bool> r = a.insert(value);
        
        if (!r.second)
        {
            // exist
            if (value.second == r.first->second)
                return false; // same
            else if (apply)
                r.first->second = value.second; // exist and update
        }
        return true;
    }
    
    inline bool replace(property_type &a,
                        uint32_t tag, const ByteBuffer &value, bool apply = true)
    {
        return replace(a, std::make_pair(tag, value), apply);
    }
    
    inline bool replace(Property &a,
                        uint32_t tag, const ByteBuffer &value, bool apply = true)
    {
        return replace(a.props, std::make_pair(tag, value), apply);
    }
    
    inline bool replace(Property &a,
                        const property_type::value_type &value, bool apply = true)
    {
        return replace(a.props, value, apply);
    }
    
    inline bool remove(Property &a, uint32_t tag, bool apply = true)
    {
        property_type::iterator i = a.props.find(tag);
        if (i != a.props.end())
        {
            // find
            if (apply) a.props.erase(i);
            return true;
        }
        else
            return false;
    }
    
    // 把b 的所有属性合并到a 中
    inline bool replace(Property &a, const Property &b, bool apply = true)
    {
        bool changed = false;
        for (property_type::const_iterator i = b.props.begin(); i != b.props.end(); ++i)
            changed = replace(a, *i, apply) || changed; // 必须放在后面，教训
        return changed;
    }
    
    // 从a 中删除所有b 中的属性
    inline bool remove(Property &a, const Property &b, bool apply = true)
    {
        bool changed = false;
        for (property_type::const_iterator i = b.props.begin(); i != b.props.end(); ++i)
            changed = remove(a, i->first, apply) || changed; // 必须放在后面，教训
        return changed;
    }
    
    inline bool replace_test(const Property &a, uint32_t tag, const ByteBuffer &value)
    {
        if (const ByteBuffer * p = find(a, tag))
            return *p != value;
        return true;
    }
    
    // 把b 中不产生效果的属性删除，不改变a
    inline void replace_diff(const Property &a, Property &b)
    {
        Property tmp;
        for (property_type::const_iterator i = b.props.begin();
             i != b.props.end(); ++i)
        {
            if (replace_test(a, i->first, i->second))
                tmp.props.insert(*i);
        }
        swap(b, tmp);
    }
    
    //////////////////////////////////////////////////////////////////////
    // Mapproperty
    inline void swap(MapProperty &a, MapProperty &b)
    {
        a.mapp.swap(b.mapp);
    }
    
    inline void replace(map2props_t &a, const map2props_t &b)
    {
        for (map2props_t::const_iterator i = b.begin(); i != b.end(); ++i)
            replace(a[i->first], i->second);
    }
    
    inline void replace(MapProperty &a, const MapProperty &b)
    {
        replace(a.mapp, b.mapp);
    }
    
    inline void replace(map2props_t &a, const MapProperty &b)
    {
        replace(a, b.mapp);
    }
    
    // 把b 的所有属性合并到a 中，不检查是否改变
    inline void replace_nocheck(ByteBuffer &a, const ByteBuffer &b)
    {
        a = b;
    }
    
    // 把b 的所有属性合并到a 中，不检查是否改变
    inline void replace_nocheck(Property &a, const Property &b)
    {
        for (property_type::const_iterator i = b.props.begin(); i != b.props.end(); ++i)
            a.props[i->first] = i->second;
    }
}  // namespace property



struct PropertyList : nbase::Marshallable
{
    std::list<Property> list_;
    
    virtual void marshal(nbase::Pack &p) const
    {
        p.push_len((uint32_t)list_.size());
        for (auto it = list_.begin() ; it != list_.end(); it++) {
            p << *it;
        }
    }
    virtual void unmarshal(const nbase::Unpack &up)
    {
        uint32_t length = up.pop_len();
        for (uint32_t i = 0; i < length; i++) {
            Property info;
            up >> info;
            list_.push_back(info);
        }
    }
};


struct StringList : nbase::Marshallable
{
    std::list<UTF8String> list_;
    
    virtual void marshal(nbase::Pack &p) const
    {
        p.push_len((uint32_t)list_.size());
        for (auto it = list_.begin() ; it != list_.end(); it++) {
            p.push_varstr(*it);
        }
    }
    virtual void unmarshal(const nbase::Unpack &up)
    {
        uint32_t length = up.pop_len();
        for (uint32_t i = 0; i < length; i++) {
            list_.push_back(up.pop_varstr());
        }
    }
};
    
}


#endif  // BIZ_PROTOCOL_PROPERTY_H_
