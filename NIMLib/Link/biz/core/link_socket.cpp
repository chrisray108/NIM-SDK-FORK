// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Zhou Jianghua <zhoujianghua@corp.netease.com>
// Date: 2011/9/27
//
// Link Socket impementation

#include "link_socket.h"
#include "link_nio_thread.h"
#include "biz/protocol/protocol.h"
#include "util/rsa_util.h"
#include "biz/core/yixin_core.h"
#include "biz/service/link/link_protocol.h"


namespace nimbiz
{

const int kSockBufferSize = 1024 * 128;


struct GetSessionKeyReqeust : nbase::Marshallable
{
    int32_t version_;
    std::string encrpyted_content_;
    void marshal(nbase::Pack &p) const
    {
        p.push_uint32(version_);
        p.push(encrpyted_content_.c_str(), encrpyted_content_.size());
    }
    virtual void unmarshal(const nbase::Unpack &up) {assert(0);}

};


LinkSocket::LinkSocket()
:close_socket_event_(false,false)
{
    link_nio_client_    = NULL;
    callback_           = NULL;
    is_encrypt_         = false;
    closing_            = false;
    connected_          = false;
    link_nio_thread_    = NULL;
    link_sender_        = NULL;

    proxy_set_.type_    = nbase::kProxyTypeNone;
}

LinkSocket::~LinkSocket()
{
    if (link_nio_thread_)
    {
        link_nio_thread_->Stop();
        delete link_nio_thread_;
        link_nio_thread_ = NULL;
    }    
    SAFE_DELETE(link_nio_client_);
    SAFE_DELETE(link_sender_);

}

#pragma mark - 连接和关闭
bool LinkSocket::Create(const nbase::ProxySet *proxy/* = NULL*/)
{
    in_chiper_ = new nbase::Encrypt_Impl();
    in_chiper_->SetMethod(nbase::ENC_ARC4);
    out_chiper_ = new nbase::Encrypt_Impl();
    out_chiper_->SetMethod(nbase::ENC_ARC4);
    link_sender_ = new LinkSender<LinkSocket>(this, false);
    

    if (proxy)
    {
        proxy_set_.host_    = proxy->host_;
        proxy_set_.port_    = proxy->port_;
        proxy_set_.type_    = proxy->type_;
        proxy_set_.username_ = proxy->username_;
        proxy_set_.password_ = proxy->password_;
    }
    return true;
}

void LinkSocket::Connect(const char *host, int port, int timeout /* = 30*/)
{
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Connect Host %s",GetDescription());
    nbase::NAutoLock lock(&nio_thread_lock_);
    // 先清理
    is_encrypt_ = false;
    connected_ = false;
    closing_ = true;
    
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Wait For Closing Socket %s",GetDescription());
    if (link_nio_thread_ && link_nio_client_)
    {
        nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Post Close Socket Task %s",GetDescription());
        close_socket_event_.Reset();
        link_nio_thread_->PostTask(new CloseSocketTask(this));
        close_socket_event_.Wait();
    }
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Socket Closed %s",GetDescription());
    SAFE_DELETE(link_nio_thread_);
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Socket Thread Closed %s",GetDescription());
    
    closing_ = false;
    link_nio_thread_ = new LinkNioThread();
    link_nio_thread_->StartWithLoop(nbase::MessageLoop::kIOMessageLoop);
    link_nio_thread_->PostTask(new ConnectSocketTask(this, host, port, timeout));
}

void LinkSocket::ConnectHelper(const char *host, uint16_t port, int timeout)
{
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Enter Connect Task %s",GetDescription());
    nbase::NAutoLock lock(&nio_thread_lock_);
    event_base *ev = link_nio_thread_->message_loop()->ToIOMessageLoop()->GetPump()->event_base();
    assert(link_nio_client_ == NULL);  //此时NIO_CLIENT必定为空
    if (link_nio_client_)
    {
        assert(0);
        nbase::DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Link Nio Client Invalid %s",GetDescription());
    }
    link_nio_client_ = new LinkNioClient<LinkSocket>(this, ev);
    
    // 连接超时时间
    nbase::TimeDelta delay = nbase::TimeDelta::FromSeconds(timeout);
    connect_timer_.Start(delay, this, &LinkSocket::OnConnectTimeout);
    
    int connect_result = link_nio_client_->Connect(host, port);
    if (-1 == connect_result && !would_block()) // 连接不上
    {
        nbase::DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Connect Error %s",GetDescription());
        OnReportLinkError(true);
        OnClose();
    }
    nbase::DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Call Connect Host %s port %d code %d %s",host,(int32_t)port,connect_result,GetDescription());
    nbase::DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Exit Connect Task %s",GetDescription());
}


bool LinkSocket::SendPacket(const LinkFrame &lf, const nbase::Marshallable &req)
{
    if (!is_encrypt_)
    {
        bool send = true;
        if (ShouldIgnoreLinkFrameBeforeEncrypted(lf))
        {
            nbase::DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "Warning: Packet Ignored %d - %d Before Being Encrypted",
                          lf.service_id_,lf.command_id_);
            send = false;
        }
        else
        {
            SendEncryptPacket(lf, req);
        }
        return send;
    }

    
    if (closing_)
    {
        if (is_encrypt_)
        {
            
        }
        else
        {
            throw nbase::NException("session not built", nbase::NIMResultTimeout); 
        }
        return false;
    }
    link_sender_->send(lf, req);
    return true;
}



void LinkSocket::Close()
{
    nbase::NAutoLock lock(&nio_thread_lock_);
    
    if (link_nio_thread_)
    {
        link_nio_thread_->PostTask(new CloseSocketTask(this));
    }
}

void LinkSocket::CloseHelper()
{
    closing_ = true;
    connected_ = false;
    out_buffer_.clear();
    is_encrypt_ = false;
    SAFE_DELETE(link_nio_client_);
    read_idle_timer_.Stop();
    hp_timer_.Stop();
    IYixinCore *core = IYixinCore_Get();
    bool is_core_logined = core != NULL && core->IsLogin();
    DEFLOG(nbase::LogInterface::LV_APP, __FILE__, __LINE__, "Info: Close Socket While Logined %d %s",is_core_logined,GetDescription());
    OnReportLinkError(!is_core_logined);
    close_socket_event_.Signal();
}

void LinkSocket::SetClosing()
{
    closing_ = true;
    connect_timer_.Stop();
    read_idle_timer_.Stop();
    hp_timer_.Stop();
    
}

#pragma mark - callback注册
void LinkSocket::RegisterCallback(ILinkSocketCallback *callback)
{
    nbase::NAutoLock lock(&callback_lock_);
    callback_ = callback;
}

void LinkSocket::UnregisterCallback()
{
    nbase::NAutoLock lock(&callback_lock_);
    callback_ = NULL;
}

    
#pragma mark - Socket Event
void LinkSocket::OnConnect()
{
    if (!in_buffer_.empty() ||
        !out_buffer_.empty())
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "On Connected, In/Out Buffer Not Empty %ld-%ld %s",
               in_buffer_.size(),out_buffer_.size(),GetDescription());
        in_buffer_.clear();
        out_buffer_.clear();
    }
    

    connect_timer_.Stop();
    connected_ = true;
    
    read_idle_timer_.Stop();
    read_idle_timer_.Start(nbase::TimeDelta::FromSeconds(30), this, &LinkSocket::OnReadIdle);
    
    {
        nbase::NAutoLock lock(&callback_lock_);
        if (callback_)
        {
            callback_->OnConnected(kNetOk);
        }
    }
}

void LinkSocket::OnClose()
{
    //缓存当前连接状态
    bool connected = connected_;
    DEFLOG(nbase::LogInterface::LV_INT, __FILE__, __LINE__,
           "LinkSocket::OnClose, socket closed, connected_: %d %s", connected,GetDescription());
    
    connect_timer_.Stop();
    CloseHelper();
    
    
    nbase::NAutoLock lock(&callback_lock_);
    if (callback_)
    {
        NetErrorCode err = (connected ? kNetError : kConnectFailed);
        callback_->OnDisConnected(err);
        DEFLOG(nbase::LogInterface::LV_INT, __FILE__, __LINE__, "LinkSocket::OnClose, Raise Callback %s",GetDescription());;
    }
    else
    {
        DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "No Callback For LinkSocket %s",GetDescription());
    }
}

void LinkSocket::OnRead()
{
    if (closing_)
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "OnRead While LinkSocket is Closed %s",GetDescription());
        return;
    }
    
    read_idle_timer_.Stop();
    hp_timer_.Stop();
    read_idle_timer_.Start(nbase::TimeDelta::FromSeconds(30), this, &LinkSocket::OnReadIdle);
    
    char buf[kSockBufferSize];
    int received = 0;
    if (link_nio_client_) 
        received = link_nio_client_->Read(buf, kSockBufferSize);
    if (received <= 0)
        return;
    
    if (is_encrypt_)
    {
        std::string tmp_buf;
        in_chiper_->Decrypt(buf, received, tmp_buf);
        in_buffer_.append(tmp_buf);
    }
    else
    {
        DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Receive Message While Not Encrypted %s",GetDescription());
    }
    ParseBuffer();
}

void LinkSocket::OnWrite()
{
    if (closing_)
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "OnWrite While LinkSocket is Closed %s",GetDescription());
        return;
    }
    
    if (out_buffer_.empty())
        return;
    
    int sended = 0;
    try 
    {
        if (link_nio_client_)
            sended = link_nio_client_->Write(out_buffer_.data(), out_buffer_.size());
    }
    catch (...) 
    {
        sended = SOCKET_ERROR;
    }
    
    if (sended == SOCKET_ERROR)
    {
        if (would_block())
            return;
        
        CloseHelper();
        {
            nbase::NAutoLock lock(&callback_lock_);
            if (callback_)
                callback_->OnDisConnected(kNetError);
        }

    }
    if (sended > 0)
    {
        out_buffer_.erase(0, sended);
    }
    
    
}

#pragma mark - 收发包
void LinkSocket::PostSendTask(const char *data, size_t length)
{
    if (closing_)
    {
        DEFLOG(nbase::LogInterface::LV_WAR, __FILE__, __LINE__, "PostSendTask While LinkSocket is Closed %s",GetDescription());
        return;
    }
    
    nbase::NAutoLock lock(&nio_thread_lock_);
    
    SendPacketTask *task = new SendPacketTask(this, data, length);
    if (link_nio_thread_)
    {
        link_nio_thread_->PostTask(task);
    }
    
}

void LinkSocket::ExcuteSend(const char *buff, size_t length)
{
    if (is_encrypt_)
    {
        std::string dest_data;
        out_chiper_->Encrypt(buff, length, dest_data);
        out_buffer_.append(dest_data);
    }
    else
    {
        out_buffer_.append(buff, length);
        is_encrypt_ = true;
    }
    
    int sended = 0;
    try
    {
        if (link_nio_client_) 
            sended = link_nio_client_->Write(out_buffer_.data(), out_buffer_.size());
    }
    catch (...)
    {
        sended = SOCKET_ERROR;
    }
    
    if (sended == SOCKET_ERROR)
    {
        if (would_block())
            return;
        
        CloseHelper();
        {
            nbase::NAutoLock lock(&callback_lock_);
            if (callback_)
                callback_->OnDisConnected(kNetError);
        }

    }
    
    if (sended > 0)
        out_buffer_.erase(0, sended);
}

static uint32_t length_from_data(const char *data,uint32_t &size)
{
    uint32_t length = 0;
    size = 0;
    int multiplier = 1;
    for (int i = 0 ; i < 4; i++)
    {
        uint8_t byte = data[i];
        length += (byte & 0x7F) * multiplier;
        multiplier *= 0x80;
        size = i +1;
        if ((byte & 0x80) == 0)
        {
            break;
        }
    }
    return length;
}

void LinkSocket::ParseBuffer()
{
    while (!in_buffer_.empty())
    {
        if (in_buffer_.size() < 4)
            break;
        
        uint32_t size = 0;
        uint32_t packet_size_exclude_frame_length = length_from_data(in_buffer_.data(), size);
        uint32_t packet_size = packet_size_exclude_frame_length + size;
		if(packet_size > in_buffer_.size())
			break;
        
		try
		{
            nbase::Unpack packetbuf(in_buffer_.data() , packet_size);			
            
			Dispatch(packetbuf);	
            
			in_buffer_.erase(0, packet_size);	
		}
		catch(std::exception &)
		{
            in_buffer_.erase(0, packet_size);
            {
               nbase::NAutoLock lock(&callback_lock_);
               if(callback_)
                    callback_->OnParseError();
            }

		}
    }
}

void LinkSocket::Dispatch(nbase::Unpack &up)
{
    nbase::NAutoLock lock(&callback_lock_);
    if (callback_ && up.size() > 0)
    {
        callback_->OnPacket(up);
    }
}

#pragma mark - 连接/读写超时
void LinkSocket::OnConnectTimeout()
{
    DEFLOG(nbase::LogInterface::LV_INT, __FILE__, __LINE__, "LinkSocket::OnConnectTimeout, connected_: %d %s", connected_,GetDescription());
    OnReportLinkError(true);
    
    {
        nbase::NAutoLock lock(&callback_lock_);
        if (callback_)
        {
            NetErrorCode err = kConnectFailed;
            callback_->OnDisConnected(err);
        }
    }
    Close();
}

void LinkSocket::OnReadIdle()
{
    DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Socket Read Idle %s",GetDescription());
    FireHeartPing();
    hp_timer_.Start(nbase::TimeDelta::FromSeconds(15), this, &LinkSocket::OnHeartPingTimeout);
}

void LinkSocket::OnHeartPingTimeout()
{
    DEFLOG(nbase::LogInterface::LV_ERR, __FILE__, __LINE__, "Heart Ping After Last  Timeout %s",GetDescription());
    CloseHelper();
    
    nbase::NAutoLock lock(&callback_lock_);
    if (callback_)
        callback_->OnDisConnected(kNetError);
}
    


#pragma mark - 加密相关方法
UTF8String LinkSocket::GetRandomRC4Key()
{
    UTF8String rc4_key;
    while (rc4_key.length() < 16)
    {
        rc4_key += nbase::StringPrintf("%u",arc4random());
    }
    return rc4_key.substr(0,16);
}
    
    

void    LinkSocket::SendEncryptPacket(const LinkFrame &lf, const nbase::Marshallable &req)
{
    //生成rc4秘钥
    UTF8String rc4_key = GetRandomRC4Key();
    in_chiper_->SetDecryptKey(rc4_key);
    out_chiper_->SetEncryptKey(rc4_key);
    nbase::PackBuffer rc4_key_buffer;
    LinkPacker rc4_key_packet(rc4_key_buffer);
    rc4_key_packet.push_varstr(rc4_key);
    
    //pack下一次的请求
    nbase::PackBuffer next_request_buffer;
    LinkPacker next_request_packet(next_request_buffer);
    next_request_packet << lf;
    next_request_packet << req;
    next_request_packet.endpack();
    
    //RSA加密
    std::string rc4_key_request_conent(rc4_key_packet.data(),rc4_key_packet.size());
    std::string next_request_content(next_request_packet.data(),next_request_packet.size());
    std::string raw_content = rc4_key_request_conent + next_request_content;
    std::string encrypted_content;
    
    UTF8String hex_module;
    int version;
    nimbiz::ReadRSAConfig(hex_module, version);
    
    nimbiz::RSAEncrypt(raw_content, hex_module,encrypted_content);
    
    GetSessionKeyReqeust key_request;
    key_request.version_ = version;
    key_request.encrpyted_content_ = encrypted_content;
    LinkFrame session_key_lf(SVID_NIM_LINK,CID_EXCHANGE_KEY);
    link_sender_->send(session_key_lf, key_request);

}
    
#pragma mark - 不同类型socket处理
void    LinkSocket::FireHeartPing()
{
    socket_type_handler_.Ping();
}
    
const char *LinkSocket::GetDescription()
{
    return socket_type_handler_.GetDescription();
}
    
void LinkSocket::OnReportLinkError(bool fatal)
{
    socket_type_handler_.ReportError(fatal);
}
    
bool LinkSocket::ShouldIgnoreLinkFrameBeforeEncrypted(const nimbiz::LinkFrame &lf)
{
    return socket_type_handler_.ShouldIngore(lf);
}
    
void LinkSocket::SetTypeHanlder(const nimbiz::LinkSocketTypeHanlder &handler)
{
    socket_type_handler_ = handler;
}

}
