// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/10/8
//
// 缓存数据管理

#ifndef BIZ_CORE_DOCUMENT_H_
#define BIZ_CORE_DOCUMENT_H_

#include <set>
#include <list>
#include "base/base_types.h"
#include "base/memory/packet.h"
#include "base/util/callback.h"
#include "biz/core/eim_task.h"
#include "base/synchronization/lock.h"
#include "biz/protocol/protocol.h"
#include "biz/protocol/property.h"
#include "service.h"

namespace nimbiz
{


#define ALL_DOC_TYPE_STR  ("*")
#define ALL_DOC_TYPE_INT  -1

#define ONLY_DOC_TYPE_STR ("")
#define ONLY_DOC_TYPE_INT 0

// TagId    可以watch CHANGED,RESETED
// ItemId   可以watch ADD,REMOVED
// DataId   可以watch REMOVED,RESETED

enum
{
    kDocChanged = 0,    //!< 数据发生改变(TagId)
    kDocRemoved = 1,    //!< 数据被删除       (DataId,ItemId) 
    kDocReseted = 2,    //!< 数据被重置       (DataId,ItemId,TagId)
    kDocAdd     = 3     //!< 数据被添加       (ItemId)  
};


typedef std::set<uint32_t> TagSet;

typedef nbase::Callback<void(UTF8String, UTF8String, TagSet, int)> IWatchHandler;


/**
 * Document发生变化时，引发的通知
 */
class DocTask : public YixinTask
{
public:
    DocTask()
    {
        event_ = kDocChanged;
    }
    
    virtual void Run();
    virtual void Release()
    {
        delete this;
    }
    
public:
    // 变更的数据名
    UTF8String data_id_;
    // 变更数据的子项名: 一般是uid
    UTF8String item_id_;
    // 变更数据的数据索引
    TagSet tags_;
    // 事件
    int event_;
    // 需要通知的对象
    std::list<IWatchHandler> handlers_;    
};  // class DocTask


struct DocTaskQueue
{
public:
    ~DocTaskQueue()
    {
        Release();
    }
    
    void PushTask(DocTask* task)
    {
        nbase::NAutoLock lock(&lock_);  
        tasks_.push_back(task);           
    }
    
    void PopTask(std::list<DocTask *>& tasks)
    {
        nbase::NAutoLock lock(&lock_);    
        tasks = tasks_;
        tasks_.clear();         
    }
    void Release()
    {
        nbase::NAutoLock lock(&lock_);   
        std::list<DocTask *>::iterator iter;
        for (iter = tasks_.begin(); iter != tasks_.end(); ++iter)
        {   
            (*iter)->Release();
        }
        tasks_.clear();
    }

private:
    std::list<DocTask *> tasks_;    
    nbase::NLock         lock_;
};


struct DocWatcher
{
    DocWatcher(void *watch_class,
               const UTF8String data_id,
               const UTF8String item_id,
               uint32_t tag_id,
               IWatchHandler &handler)
        : watch_class_(watch_class),
          data_id_(data_id),
          item_id_(item_id),
          tag_id_(tag_id),
          handler_(handler)
    {           
    }
        
    void Collect(DocTask *task)
    {
        if(NULL != task)
        {
            if (data_id_ != task->data_id_)
                return;
            
            if (item_id_ == ONLY_DOC_TYPE_STR)
            {
                // 只Watch DataId的变化
                if (task->item_id_ != ONLY_DOC_TYPE_STR)
                    return;
            }
            else
            {
                if (item_id_ != ALL_DOC_TYPE_STR &&
                    task->item_id_ != ALL_DOC_TYPE_STR &&
                    item_id_ != task->item_id_)
                    return;
                
                if (tag_id_ == ONLY_DOC_TYPE_INT)
                {
                    // 只watch ItemId的变化
                    if (task->tags_.find(ONLY_DOC_TYPE_INT) == task->tags_.end())
                        return;
                }
                else
                {
                    if (tag_id_ != ALL_DOC_TYPE_INT &&
                        task->tags_.size() > 0 &&
                        task->tags_.find(tag_id_) == task->tags_.end())
                        return;
                }
            }
            
            if (!handler_.is_null())
                task->handlers_.push_back(handler_);
        }
    }
    
    // 发出watch的Class
    void* watch_class_;
    //被watch的数据名
    UTF8String data_id_;
    //被watch的数据子项名
    UTF8String item_id_;
    //被watch的数据index
    uint32_t tag_id_;
    // 被watch的事件
    uint32_t event_id;
    //回调对象
    IWatchHandler handler_;
};


/**
 *  DocDataset
 *  @discussion 原document中有3个标记位，分别是:是否需要缓存，是否需要同步，是否需要本地存储，已废弃，但为了保证序列化的正确性,保留这3个字段
 */
struct DocDataset : public MapProperty
{
    bool is_dirty_;
    
    void reset(const MapProperty &prop)
    {
        mapp = prop.mapp;
    }
    void cleardata()
    {
        mapp.clear();
    }
    virtual void marshal(nbase::Pack &p) const
    {
        bool deprecated_flag = true;
        p << deprecated_flag;
        p << deprecated_flag;
        p << deprecated_flag;
        MapProperty::marshal(p);
    }
    
    virtual void unmarshal(nbase::Unpack &up)
    {
        bool deprecated_flag = true;
        up >> deprecated_flag;
        up >> deprecated_flag;
        up >> deprecated_flag;
        MapProperty::unmarshal(up);
    }
    
    DocDataset()
        : is_dirty_(false)
    {}
};

 
class Document
{
public:
    Document();
    ~Document();
    
// 监听数据变更    
public:
    void  Watch(void *watch_class,
                IWatchHandler &handler,
                const UTF8String &data_id = UTF8String(ALL_DOC_TYPE_STR),
                const UTF8String &item_id = UTF8String(ALL_DOC_TYPE_STR),
                uint32_t tag = ALL_DOC_TYPE_INT);
    void Revoke(IWatchHandler &handler);
    void Revoke(void *watch_class);
    void RevokeAll();
    void Collect(DocTask *task);
   
//数据存取
public:                 
    void Save();
    void Load();
    
// 数据修改
public:
    void OpenData(IService *service,
                  const UTF8String &data_id,
                  bool need_cache,
                  bool need_sync,
                  bool need_local = false);
    
    void GetAllDatas(std::list<UTF8String> &keys);

    
    void GetDataItems(const UTF8String &data_id, std::list<UTF8String> &keys);
    
    void GetDataItems(const UTF8String &data_id,
                      const UTF8String &prefix,
                      std::list<Property> &infos);
    
    
    bool HasDataItem(const UTF8String &data_id, const UTF8String &item_id);
    
    void GetDataItem(const UTF8String &data_id,
                     const UTF8String &item_id,
                     Property &prop);
    
    DocTask* SetDataItem(const UTF8String &data_id,
                         const UTF8String &item_id,
                         const Property &prop);
    
    DocTask* DeleteDataItem(const UTF8String &data_id,
                            const UTF8String &item_id);
    
    void GetDataItemTag(const UTF8String &data_id,
                        const UTF8String &item_id,
                        const uint32_t tag_id,
                        ByteBuffer &value,
                        bool *check);
    
    DocTask* SetDataItemTag(const UTF8String &data_id,
                            const UTF8String &item_id,
                            const uint32_t tag_id,
                            const ByteBuffer &value);
    
    bool IsWatchHandlerExist(IWatchHandler &handler);
    
    uint32_t DocumentStorageSize();
 
protected:
    void LoadFile(std::string filepath, bool encrypt);

public:
    typedef std::list<DocWatcher *> WatchList;

private:
    std::map<UTF8String, DocDataset> datas_;  
    WatchList watchers_;    
    nbase::NLock watch_lock_; // watch读写锁
    nbase::NLock datas_lock_; // 数据读写锁 
};
    
}

#endif  // BIZ_CORE_DOCUMENT_H_
