// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/8
//
// 缓存数据管理

#include "document.h"
#include "yixin_core.h"
#include "base/file/file_util.h"
#include "util/ios_util.h"

#define kUserFilename  "nim_document.cache"

namespace nimbiz
{

/////////////////////////////////////////////////////////////////
// DockTask
void DocTask::Run()
{    
    //handler
    std::list<IWatchHandler>::iterator iter = handlers_.begin();
    std::list<IWatchHandler> handlers_active;
    for (; iter != handlers_.end(); ++iter)
    {
        // 防止在handler处理的时候把IYixinCore给搞掉了，比如在被踢掉的时候
        IYixinCore *popo = IYixinCore_Get();
        if (NULL == popo)
            return;
        
        // 判断运行环境是否发生变化
        if (popo->IsQuiting())
            break;
        
        IWatchHandler handler = (*iter);
        if (popo->IsWatchHandlerExist(handler))
        {
            handler.Run(data_id_, item_id_, tags_, event_);
            handlers_active.push_back(handler);
        }        
    }
    
    handlers_.clear();
    handlers_ = handlers_active;
}


/////////////////////////////////////////////////////////////////
// Document
Document::Document()
{
    
}

Document::~Document(void)
{
    WatchList::iterator iter = watchers_.begin();
    for (;iter != watchers_.end();iter++)
    {
        delete *iter;
    }
    watchers_.clear();
    datas_.clear();
}

void Document::Watch(void *watch_class,
                     IWatchHandler &handler,
                     const UTF8String &data_id,
                     const UTF8String &item_id,
                     uint32_t tag)
{
    DocWatcher *watcher = new DocWatcher(watch_class, data_id, item_id, tag, handler);
    watch_lock_.Lock();
    watchers_.push_back(watcher);
    watch_lock_.Unlock();
}

void Document::Revoke(IWatchHandler &handler)
{
    watch_lock_.Lock();
    WatchList::iterator iter = watchers_.begin();
    while (iter != watchers_.end())
    {
        DocWatcher *watcher = (*iter);
        if (watcher->handler_.Equals(handler))
        {
            iter = watchers_.erase(iter);
            delete watcher;
            watcher = NULL;
            break;
        }
        else
            iter++;
    }
    watch_lock_.Unlock();
}

void Document::Revoke(void *watch_class)
{
    std::vector<IWatchHandler> vc_remove;    // 用来临时存放要被删除的item
    
    watch_lock_.Lock();
    WatchList::iterator iter = watchers_.begin();
    while (iter != watchers_.end())
    {
        DocWatcher *watcher = (*iter);
        if(watcher->watch_class_ == watch_class)
        {
            vc_remove.push_back(watcher->handler_);
        }
        
        iter++;
    }
    watch_lock_.Unlock();
    
    // 再分别删除每一个
    for (std::vector<IWatchHandler>::iterator it = vc_remove.begin(); 
         it != vc_remove.end(); ++it)
    {
        IWatchHandler handle = *it;
        Revoke(handle);
    }
}

void Document::RevokeAll()
{
    watch_lock_.Lock();
    WatchList::iterator iter = watchers_.begin();
    for (; iter != watchers_.end(); ++iter)
    {
        delete *iter;
    }
    watchers_.clear();
    watch_lock_.Unlock();
}

void Document::Collect(DocTask *task)
{
    watch_lock_.Lock();    
    WatchList::iterator iter = watchers_.begin();
    for (; iter != watchers_.end(); ++iter)
    {
        (*iter)->Collect(task);
    }
    watch_lock_.Unlock();
}

void Document::Save()
{
    std::string user_dir = nimbiz::GetUserDirectory();

    datas_lock_.Lock();
    
    // 1) 将需要缓存的数据拷贝到缓存区
    bool should_save  = false;
    for (auto i = datas_.begin() ; i != datas_.end(); ++i)
    {
        DocDataset &data = i->second;
        if (data.is_dirty_)
        {
            data.is_dirty_ = false;
            should_save = true;
        }
    }
    
    // 如果数据脏,则进行一次保存
    if (should_save)
    {
         // 2) 将缓存数据写入到Pack中
        nbase::PackBuffer buf;
        nbase::Pack pack(buf);
        
        for (auto i = datas_.begin(); i != datas_.end(); ++i)
        {
            pack << i->first;
            i->second.marshal(pack);
        }
        
        
        //先写入到暂存文件，然后再拷贝覆盖
        std::string data_file, data_temp;
        nbase::FilePathCompose(user_dir, kUserFilename, data_file);
        data_temp = data_file + ".tmp";
        
        if (nbase::FilePathIsExist(data_temp, false))
            nbase::DeleteFile(data_temp);
        int ret = nbase::WriteFile(data_temp.c_str(), pack.data(), (int)pack.size());
        if (ret)
        {
            nbase::CopyFile(data_temp, data_file);
            nbase::DeleteFile(data_temp);
        }
    }
    datas_lock_.Unlock();
}

void Document::Load()
{
    std::string user_dir = nimbiz::GetUserDirectory();
    std::string data_file;
    nbase::FilePathCompose(user_dir, kUserFilename, data_file);
    
    LoadFile(data_file, false);
}


void Document::GetAllDatas(std::list<UTF8String> &keys)
{
    datas_lock_.Lock();
    
    WatchList::iterator iter = watchers_.begin();
    for (; iter != watchers_.end(); ++iter)
    {
        keys.push_back((*iter)->data_id_);
    }
    
    datas_lock_.Unlock();
}



void Document::GetDataItems(const UTF8String &data_id, std::list<UTF8String> &keys)
{
    datas_lock_.Lock();
    
    // 检查数据是否已经存在
    const DocDataset &data = datas_[data_id];
    for (map2props_t::const_iterator i = data.mapp.begin(); i != data.mapp.end(); ++i)
    {
        keys.push_back(i->first);
    }
    datas_lock_.Unlock();
}

void Document::GetDataItems(const UTF8String &data_id,
                            const UTF8String &prefix,
                            std::list<Property> &infos)
{
    datas_lock_.Lock();
    
    
    const DocDataset &data = datas_[data_id];
    map2props_t::const_iterator begin_it = data.mapp.lower_bound(prefix);
    for (map2props_t::const_iterator it = begin_it;it != data.mapp.end(); it++)
    {
        if (it->first.find(prefix) == 0)
        {
            infos.push_back(it->second);
        }
        else
        {
            break;
        }
    }
    
    
    datas_lock_.Unlock();
}



bool Document::HasDataItem(const UTF8String &data_id, const UTF8String &item_id)
{
    datas_lock_.Lock();
    
    bool result = 
        datas_[data_id].mapp.find(item_id) != datas_[data_id].mapp.end();
    
    datas_lock_.Unlock();
    
    return result;
}

void Document::GetDataItem(const UTF8String &data_id,
                           const UTF8String &item_id,
                           Property &prop)
{
    datas_lock_.Lock();
    
    prop = datas_[data_id].get(item_id);     
    
    datas_lock_.Unlock();
}

DocTask* Document::SetDataItem(const UTF8String &data_id,
                               const UTF8String &item_id,
                               const Property &prop)
{
    DocTask *task = new DocTask();
    task->data_id_ = data_id;
    task->item_id_ = item_id;
    for (property_type::const_iterator i = prop.props.begin(); 
         i != prop.props.end(); ++i)
    {
        task->tags_.insert(i->first);
    }

    datas_lock_.Lock();
    
    datas_[data_id].is_dirty_ = true;
    
    if (datas_[data_id].mapp.find(item_id) != datas_[data_id].mapp.end())
    {
        task->event_ = kDocChanged;
    }
    else
    {
        task->event_ = kDocAdd;
        task->tags_.insert(ONLY_DOC_TYPE_INT);
    }

    property::replace(datas_[data_id].mapp[item_id], prop);
    
    datas_lock_.Unlock();
    
    this->Collect(task);
    return task;
}

DocTask* Document::DeleteDataItem(const UTF8String &data_id,
                                  const UTF8String &item_id)
{
    DocTask *task = new DocTask();
    task->data_id_ = data_id;
    task->item_id_ = item_id;
    task->event_ = kDocRemoved;
    
    datas_lock_.Lock();
    
    datas_[data_id].is_dirty_ = true;
    
    datas_[data_id].mapp.erase(item_id);
    
    datas_lock_.Unlock();
    
    this->Collect(task);
    return task;
}

void Document::GetDataItemTag(const UTF8String &data_id,
                              const UTF8String &item_id,
                              const uint32_t tag_id,
                              ByteBuffer &value,
                              bool *check)
{
    datas_lock_.Lock();
    
    Property prop = datas_[data_id].get(item_id);
    
    if (check)
    {
        property_type::const_iterator i = prop.props.find(tag_id);
        *check = (i != prop.props.end()) ? true : false;
    }
    
    value = prop.get(tag_id);
    
    datas_lock_.Unlock();
}

DocTask* Document::SetDataItemTag(const UTF8String &data_id,
                                  const UTF8String &item_id,
                                  const uint32_t tag_id,
                                  const ByteBuffer &value)
{
    DocTask *task = new DocTask();
    task->data_id_ = data_id;
    task->item_id_ = item_id;
    task->tags_.insert(tag_id);   
    
    task->event_ = kDocChanged;    // Tag只有Change, 没有Add
    
    datas_lock_.Lock();
    
    datas_[data_id].is_dirty_ = true;
    
    property::replace(datas_[data_id].mapp[item_id], tag_id, value);
    
    datas_lock_.Unlock();
    
    this->Collect(task);
    return task;
}

bool Document::IsWatchHandlerExist(IWatchHandler &handler)
{
    watch_lock_.Lock();
    WatchList::iterator iter = watchers_.begin();
    while (iter != watchers_.end())
    {
        DocWatcher *watcher = (*iter);
        if (watcher->handler_.Equals(handler))
        {
            watch_lock_.Unlock();
            return true;
        }
        else
            iter++;
    }
    watch_lock_.Unlock();

    return false;
}

uint32_t    Document::DocumentStorageSize()
{
    uint32_t size = 0;
#ifdef DEBUG
    datas_lock_.Lock();
    
    //估算一个Document占用的时间,只计算当前Document内string长度和uint32占用的内存大小
    //document中的string有大量相同字符串，所以足够抵消掉没有计算:map结构所占用内存消耗和string内部结构占用量
    //最终计算出的结果应该比真实内存占用量大
    
    
    for (std::map<UTF8String, DocDataset>::iterator dn_it = datas_.begin();
         dn_it != datas_.end(); dn_it++)
    {
        size += dn_it->first.size() + 4;
        std::map<UTF8String, Property> &mapp = dn_it->second.mapp;
        for (std::map<UTF8String, Property>::iterator item_it = mapp.begin();
             item_it != mapp.end(); item_it++)
        {
            size += dn_it->first.size() + 4;
            std::map<uint32_t, UTF8String> &props = item_it->second.props;
            for (std::map<uint32_t, UTF8String>::iterator p_it = props.begin();
                 p_it != props.end() ; p_it++)
            {
                size += 4;
                size += p_it->second.size() + 4;
            }
        }
    }
    datas_lock_.Unlock();
#endif
    return size;
}

void Document::LoadFile(std::string filepath, bool encrypt)
{
    if (nbase::FilePathIsExist(filepath, false) == false)
        return;
    
    ByteBuffer  buffer;    
    nbase::ReadFileToString(filepath, buffer);
    
    //进行序列化操作
    nbase::Unpack up(buffer.data(), buffer.size());
    // 锁定数据
    datas_lock_.Lock();           
    UTF8String data_id;
    try
    {       
        //读取所有的配置到数据结构里面
        while (!up.empty())
        {
            DocDataset dataset;
            
            up >> data_id;
            dataset.unmarshal(up);
            dataset.is_dirty_ = false;
            datas_[data_id] = dataset;
            
        }
    }
    catch (std::runtime_error&)
    {
        assert(0);
        datas_.clear();
    }
    // 解除数据锁定
    datas_lock_.Unlock();
}

}
