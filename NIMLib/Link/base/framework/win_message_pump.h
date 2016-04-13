// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/6/8
//
// The base class of a cross flatform message pump implemention

#ifndef BASE_FRAMEWORK_WIN_MESSAGE_PUMP_H_
#define BASE_FRAMEWORK_WIN_MESSAGE_PUMP_H_

#include "base/framework/message_pump.h"

#if defined(OS_WIN)
#include <windows.h>
#include "base/time/time.h"

namespace nbase
{

class BASE_API WinMessagePump: public MessagePump
{
public:

	//	UI��Ϣ�ɷ���
	//	UI��Ϣ�����ʹ����Ϣ�ɷ�������ô������ʹ�þ����
	//	TranslateMessage/DispatchMessageģʽ������Dispatcher�����
	class BASE_API Dispatcher
	{
	public:

		virtual ~Dispatcher() {}
		virtual bool Dispatch(const MSG& message) = 0;
	};

	WinMessagePump() : have_work_(0), state_(NULL) {}
	virtual ~WinMessagePump() {}

	void RunWithDispatcher(Delegate* delegate, Dispatcher* dispatcher);

	virtual void Run(Delegate* delegate) { return RunWithDispatcher(delegate, NULL); }
	virtual void Quit();

protected:
	struct RunState
	{
		int run_depth;				// Ƕ�׵������
		bool should_quit;			// �Ƿ�Ӧ�������˳�
		Delegate* delegate;			// ���������ί��
		Dispatcher* dispatcher;		// ��Ϣ�ɷ���
	};

	// ȡ��ǰ��ʱ���
	int64_t GetCurrentDelay() const;
	virtual void DoRunLoop() = 0;

	// ��ʱ�����´����е�ʱ��
	TimeTicks delayed_work_time_;

	// ָʾ��Ϣ�������Ƿ���kMsgDoWork��Ϣ
	long have_work_;

	// ָʾ��ǰMessagePump��״̬
	RunState* state_;
};

}

#endif  // OS_WIN

#endif // BASE_FRAMEWORK_WIN_MESSAGE_PUMP_H_
