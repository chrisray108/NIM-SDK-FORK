// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/11/6
//
// Network utility function

#include "network_util.h"
#include "base/util/string_util.h"
#include <sstream>
#include <stdlib.h>

#if defined (OS_WIN)
#include "nb30.h"
#else
#include <net/if_dl.h>
#if defined (OS_IOS) && !defined (IFT_ETHER)
#define IFT_ETHER   0x06 /* Ethernet CSMACD */ 
#else
#include <net/if_types.h>
#endif
#include <ifaddrs.h>
#endif

namespace nbase 
{

bool GetIpAddressList(std::vector<uint32_t> &ip_addresses)
{
    ip_addresses.clear();
    
    char host_name[128];
    if (::gethostname(host_name, sizeof(host_name)) == 0)
    {
        struct hostent *host;
        host = ::gethostbyname(host_name);
        for (int i = 0; host != NULL && host->h_addr_list[i] != NULL; ++i) 
        {
            char *ip = ::inet_ntoa(*(struct in_addr*)host->h_addr_list[i]);
            if (ip)
            {
                ip_addresses.push_back(InetStringToNumber(ip));
            }
        }
    }
    return ip_addresses.size() > 0; 
}

bool GetIpAddressList(std::vector<std::string> &ip_addresses)
{
    ip_addresses.clear();
    
    char host_name[128];
    std::string ip_address;
    if (::gethostname(host_name, 128) == 0)
    {
        struct hostent *host;
        host = ::gethostbyname(host_name);
        for (int i = 0; host != NULL && host->h_addr_list[i] != NULL; ++i) 
        {
            char *ip = ::inet_ntoa(*(struct in_addr*)host->h_addr_list[i]);
            if (ip)
            {
                ip_address.assign(ip, strlen(ip));
                ip_addresses.push_back(ip_address);
            }
        }
    }
    return ip_addresses.size() > 0;        
}

#if defined(OS_WIN)
typedef struct _ASTAT  
{  
	ADAPTER_STATUS adapt;  
	NAME_BUFFER NameBuffer[30];  
}ASTAT, *PASTAT;
#endif
bool GetMacAddress(std::string &mac_address)
{
#if defined (OS_WIN)
	mac_address = ("unknowuser00");   
	ASTAT     Adapter;  
	NCB       Ncb;  
	UCHAR     uRetCode;  
	LANA_ENUM lenum;  
	int       i;  
	memset(&Ncb, 0, sizeof(Ncb));
	Ncb.ncb_command = NCBENUM;  
	Ncb.ncb_buffer  = (UCHAR *)&lenum;  
	Ncb.ncb_length  = sizeof(lenum);  
	uRetCode        = Netbios(&Ncb);  
	for (i=0; i < lenum.length; ++i)  
	{  
		memset(&Ncb, 0, sizeof(Ncb));  
		Ncb.ncb_command  = NCBRESET;  
		Ncb.ncb_lana_num = lenum.lana[i];  
		uRetCode         = Netbios(&Ncb);                                       
		memset(&Ncb, 0, sizeof(Ncb));  
		Ncb.ncb_command  = NCBASTAT;  
		Ncb.ncb_lana_num = lenum.lana[i];  
		strcpy((char *)Ncb.ncb_callname, "*                               ");  
		Ncb.ncb_buffer   = (unsigned char *)&Adapter;  
		Ncb.ncb_length   = sizeof(Adapter);  
		uRetCode         = Netbios(&Ncb);  
		if (uRetCode == 0)  
		{  
			if (Adapter.adapt.adapter_address[0]+  
				Adapter.adapt.adapter_address[1]+  
				Adapter.adapt.adapter_address[2]+  
				Adapter.adapt.adapter_address[3]+  
				Adapter.adapt.adapter_address[4]+  
				Adapter.adapt.adapter_address[5]!=0)  
			{
				StringPrintf(mac_address, "%02x-%02x-%02x-%02x-%02x-%02x",  
					         Adapter.adapt.adapter_address[0],  
					         Adapter.adapt.adapter_address[1],  
					         Adapter.adapt.adapter_address[2],  
					         Adapter.adapt.adapter_address[3],  
					         Adapter.adapt.adapter_address[4],  
					         Adapter.adapt.adapter_address[5]);  
				break;  
			}  
		}
	}
	return true;
#else    
    bool  success;
    struct ifaddrs *addrs;
    struct ifaddrs *cursor;
    const struct sockaddr_dl *dl_addr;
    success = (getifaddrs(&addrs) == 0);
    
    if (success) 
    {
        cursor = addrs;
        while (cursor != 0) 
        {
            if ((cursor->ifa_addr->sa_family == AF_LINK)
                && (((const struct sockaddr_dl *)cursor->ifa_addr)->sdl_type == IFT_ETHER))
            {
                dl_addr = (const struct sockaddr_dl *)cursor->ifa_addr;         
                const unsigned char* base = (const unsigned char *)&dl_addr->sdl_data[dl_addr->sdl_nlen];
                
                mac_address.clear();
                for (int i = 0; i < dl_addr->sdl_alen; i++)
                {
                    if (i != 0) 
                    {
                        mac_address.append(":");
                    }
                    char partial_addr[3];    
                    sprintf(partial_addr, "%02X", base[i]);
                    mac_address.append(partial_addr, 2);   
                }
                break;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);  
    } 
    return success;
#endif
}

/*
 * 检查是否为以下三类内网ip
 * A类: 10.0.0.0 ~ 10.255.255.255
 * B类: 172.16.0.0 ~ 172.31.255.255
 * C类: 192.168.0.0 ~ 192.168.255.255
 */
bool IsInternalIP(const uint32_t ip)
{
    if ((ip >= 0x0A000000 && ip <= 0x0AFFFFFF) ||
        (ip >= 0xAC100000 && ip <= 0xAC1FFFFF) ||
        (ip >= 0xC0A80000 && ip <= 0xC0A8FFFF))
        return true;
    else
        return false;    
}
    
bool IsInternalIP(const std::string &ip)
{
    return IsInternalIP(InetStringToNumber(ip));        
}

uint32_t InetStringToNumber(const char *ip)
{
    if (NULL == ip)
        return 0;
    return ntohl(::inet_addr(ip));
}
    
uint32_t InetStringToNumber(const std::string &ip)
{
    return InetStringToNumber(ip.c_str());
}
    
std::string InetNumberToString(uint32_t ip)
{
    struct in_addr in;
    in.s_addr = htonl(ip);
    return std::string(::inet_ntoa(in));
}
    
std::string MakeNetAddress(const uint32_t ip, const uint16_t port)
{
    std::stringstream buf;
    buf << InetNumberToString(ip) << ":" << port ;
    return buf.str();
}
    
std::string MakeNetAddress(const std::string &ip, const uint16_t port)
{
    std::stringstream buf;
    buf << ip << ":" << port ;
    return buf.str();      
}

bool AnalyzeNetAddress(const std::string &address, uint32_t &out_ip, uint16_t &out_port)
{
    std::list<std::string> ip_and_port;
    StringTokenize(address, ":", ip_and_port);
    if (ip_and_port.size() != 2)
        return false;
    
    out_ip = InetStringToNumber(*(ip_and_port.begin()));
    ip_and_port.pop_front();
    out_port = atoi((*(ip_and_port.begin())).c_str());
    return true ;
}
    
}  // namespace nbase
