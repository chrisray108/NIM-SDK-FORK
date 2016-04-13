﻿// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Wang Rongtao <rtwang@corp.netease.com>
// Date: 2011/06/16
//
// This file defines all kinds of tasks

#ifndef BASE_FRAMEWORK_TASK_H_
#define BASE_FRAMEWORK_TASK_H_

#include "base/base_api.h"
#include "base/memory/ref_count.h"
#include "base/util/tuple.h"

namespace nbase
{
const size_t kDeadTask = 0xDEAD7A53;

// Task用于让某个MessageLoop异步地完成某项工作。
// Task对象本身是线程安全，一个Task可以在同一个线程中生成并运行，也可以在一个线程生成在另一个线程运行，
// 后者的Run函数编写需要注意跨线程运行的问题。
// Task通过MessageLoop的Post族函数被加入到MessageLoop中运行，
// 一旦被加入到MessageLoop中，生成Task的线程不应该再负责Task的销毁而改由MessageLoop所运行的线程负责。

class BASE_API Task : public ThreadSafeRefCount
{
public:
	virtual ~Task() {}
	virtual void Run() = 0;
};

// CancelableTask定义了可撤销的任务

class BASE_API CancelableTask : public Task
{
public:
	CancelableTask() {}
	virtual ~CancelableTask() {}
	virtual void Cancel() = 0;
};

// DeleteTask用于异步删除一个对象，可撤销
template<class T>
class DeleteTask : public CancelableTask
{
public:
	explicit DeleteTask(const T* obj) : obj_(obj)
	{

	}
	
	virtual void Run()
	{
		delete obj_;
	}

	virtual void Cancel()
	{
		obj_ = NULL;
	}

private:
	const T* obj_;
};

// ReleaseTask用于异步解除对一个对象的引用，可撤销
template<class T>
class ReleaseTask : public CancelableTask
{
public:
	explicit ReleaseTask(const T* obj) : obj_(obj)
	{

	}
	
	virtual void Run()
	{
		if (obj_)
			obj_->Release();
	}

	virtual void Cancel()
	{
		obj_ = NULL;
	}

private:
	const T* obj_;
};


// RunnableMethodTraits --------------------------------------------------------
//
// This traits-class is used by RunnableMethod to manage the lifetime of the
// callee object.  By default, it is assumed that the callee supports AddRef
// and Release methods.  A particular class can specialize this template to
// define other lifetime management.  For example, if the callee is known to
// live longer than the RunnableMethod object, then a RunnableMethodTraits
// struct could be defined with empty RetainCallee and ReleaseCallee methods.

template <class T>
struct RunnableMethodTraits
{
	RunnableMethodTraits()
	{
	}

	~RunnableMethodTraits()
	{
	}

	void RetainCallee(T* obj)
	{
		obj->AddRef();
	}

	void ReleaseCallee(T* obj)
	{
		obj->Release();
	}
};

// Convenience macro for declaring a RunnableMethodTraits that disables
// refcounting of a class.  This is useful if you know that the callee
// will outlive the RunnableMethod object and thus do not need the ref counts.
//
// The invocation of DISABLE_RUNNABLE_METHOD_REFCOUNT should be done at the
// global namespace scope.  Example:
//
//   namespace foo {
//   class Bar {
//     ...
//   };
//   }  // namespace foo
//
//   DISABLE_RUNNABLE_METHOD_REFCOUNT(foo::Bar);
//
// This is different from DISALLOW_COPY_AND_ASSIGN which is declared inside the
// class.
#define DISABLE_RUNNABLE_METHOD_REFCOUNT(TypeName) \
	template <>                                    \
struct RunnableMethodTraits<TypeName>              \
{                                                  \
	void RetainCallee(TypeName* manager) {}        \
	void ReleaseCallee(TypeName* manager) {}       \
}

// RunnableMethod and RunnableFunction -----------------------------------------
//
// Runnable methods are a type of task that call a function on an object when
// they are run. We implement both an object and a set of NewRunnableMethod and
// NewRunnableFunction functions for convenience. These functions are
// overloaded and will infer the template types, simplifying calling code.
//
// The template definitions all use the following names:
// T                - the class type of the object you're supplying
//                    this is not needed for the Static version of the call
// Method/Function  - the signature of a pointer to the method or function you
//                    want to call
// Param            - the parameter(s) to the method, possibly packed as a Tuple
// A                - the first parameter (if any) to the method
// B                - the second parameter (if any) to the method
//
// Put these all together and you get an object that can call a method whose
// signature is:
//   R T::MyFunction([A[, B]])
//
// Usage:
// PostTask(NewRunnableMethod(object, &Object::method[, a[, b]])
// PostTask(NewRunnableFunction(&function[, a[, b]])

// RunnableMethod and NewRunnableMethod implementation -------------------------

template <class T, class Method, class Params>
class RunnableMethod : public CancelableTask
{
public:
	RunnableMethod(T *obj, Method meth, const Params &params)
		: obj_(obj), meth_(meth), params_(params)
	{
		traits_.RetainCallee(obj_);
// 		COMPILE_ASSERT(
// 			(base::internal::ParamsUseScopedRefptrCorrectly<Params>::value),
// 			badrunnablemethodparams);
	}

	~RunnableMethod()
	{
		ReleaseCallee();
		obj_ = reinterpret_cast<T*>(nbase::kDeadTask);
	}

	virtual void Run()
	{
		if (obj_)
			DispatchToMethod(obj_, meth_, params_);
	}

	virtual void Cancel()
	{
		ReleaseCallee();
	}

private:
	void ReleaseCallee()
	{
		T* obj = obj_;
		obj_ = NULL;
		if (obj)
			traits_.ReleaseCallee(obj);
	}

	T* obj_;
	Method meth_;
	Params params_;
	RunnableMethodTraits<T> traits_;
};

template <class T, class Method>
inline CancelableTask* NewRunnableMethod(T* object, Method method)
{
	return new RunnableMethod<T, Method, Tuple0>(object, method, MakeTuple());
}

template <class T, class Method, class A>
inline CancelableTask* NewRunnableMethod(T* object, Method method, const A& a)
{
	return new RunnableMethod<T, Method, Tuple1<A> >(object,
		method,
		MakeTuple(a));
}

template <class T, class Method, class A, class B>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b)
{
	return new RunnableMethod<T, Method, Tuple2<A, B> >(object, method,
		MakeTuple(a, b));
}

template <class T, class Method, class A, class B, class C>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b, const C& c)
{
	return new RunnableMethod<T, Method, Tuple3<A, B, C> >(object, method,
		MakeTuple(a, b, c));
}

template <class T, class Method, class A, class B, class C, class D>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b,
	const C& c, const D& d)
{
	return new RunnableMethod<T, Method, Tuple4<A, B, C, D> >(object, method,
		MakeTuple(a, b,	c, d));
}

template <class T, class Method, class A, class B, class C, class D, class E>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b,
	const C& c, const D& d, const E& e)
{
	return new RunnableMethod<T,
			Method,	
			Tuple5<A, B, C, D, E> >(object,	
			method,
			MakeTuple(a, b, c, d, e));
}

template <class T, class Method, class A, class B, class C, class D, class E,
class F>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b,
	const C& c, const D& d, const E& e,
	const F& f)
{
	return new RunnableMethod<T,
			Method,
			Tuple6<A, B, C, D, E, F> >(object,
			method,
			MakeTuple(a, b, c, d, e,
			f));
}

template <class T, class Method, class A, class B, class C, class D, class E,
class F, class G>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b,
	const C& c, const D& d, const E& e,
	const F& f, const G& g)
{
	return new RunnableMethod<T,
			Method,
			Tuple7<A, B, C, D, E, F, G> >(object,
			method,
			MakeTuple(a, b, c, d,
			e, f, g));
}

template <class T, class Method, class A, class B, class C, class D, class E,
class F, class G, class H>
inline CancelableTask* NewRunnableMethod(T* object, Method method,
	const A& a, const B& b,
	const C& c, const D& d, const E& e,
	const F& f, const G& g, const H& h)
{
	return new RunnableMethod<T,
			Method,
			Tuple8<A, B, C, D, E, F, G, H> >(object,
			method,
			MakeTuple(a, b, c,
			d, e, f,
			g, h));
}

// RunnableFunction and NewRunnableFunction implementation ---------------------

template <class Function, class Params>
class RunnableFunction : public Task
{
public:
	RunnableFunction(Function function, const Params& params)
		: function_(function), params_(params)
	{
// 		COMPILE_ASSERT(
// 			(base::internal::ParamsUseScopedRefptrCorrectly<Params>::value),
// 			badrunnablefunctionparams);
	}

	~RunnableFunction()
	{
		function_ = reinterpret_cast<Function>(nbase::kDeadTask);
	}

	virtual void Run()
	{
		if (function_)
			DispatchToFunction(function_, params_);
	}

private:
	Function function_;
	Params params_;
};

template <class Function>
inline Task* NewRunnableFunction(Function function)
{
	return new RunnableFunction<Function, Tuple0>(function, MakeTuple());
}

template <class Function, class A>
inline Task* NewRunnableFunction(Function function, const A& a)
{
	return new RunnableFunction<Function, Tuple1<A> >(function, MakeTuple(a));
}

template <class Function, class A, class B>
inline Task* NewRunnableFunction(Function function, const A& a, const B& b)
{
	return new RunnableFunction<Function, Tuple2<A, B> >(function,
		MakeTuple(a, b));
}

template <class Function, class A, class B, class C>
inline Task* NewRunnableFunction(Function function, const A& a, const B& b,
	const C& c)
{
	return new RunnableFunction<Function, Tuple3<A, B, C> >(function,
			MakeTuple(a, b, c));
}

template <class Function, class A, class B, class C, class D>
inline Task* NewRunnableFunction(Function function, const A& a, const B& b,
	const C& c, const D& d)
{
	return new RunnableFunction<Function, Tuple4<A, B, C, D> >(function,
			MakeTuple(a, b,
			c, d));
}

template <class Function, class A, class B, class C, class D, class E>
inline Task* NewRunnableFunction(Function function, const A& a, const B& b,
	const C& c, const D& d, const E& e)
{
	return new RunnableFunction<Function, Tuple5<A, B, C, D, E> >(function,
			MakeTuple(a, b,
			c, d,
			e));
}

template <class Function, class A, class B, class C, class D, class E,
class F>
	inline Task* NewRunnableFunction(Function function, const A& a, const B& b,
	const C& c, const D& d, const E& e,
	const F& f)
{
	return new RunnableFunction<Function, Tuple6<A, B, C, D, E, F> >(function,
			MakeTuple(a, b, c, d, e, f));
}

template <class Function, class A, class B, class C, class D, class E,
class F, class G>
	inline Task* NewRunnableFunction(Function function, const A& a, const B& b,
	const C& c, const D& d, const E& e, const F& f,
	const G& g)
{
	return new RunnableFunction<Function, Tuple7<A, B, C, D, E, F, G> >(function,
			MakeTuple(a, b, c, d, e, f, g));
}

template <class Function, class A, class B, class C, class D, class E,
class F, class G, class H>
	inline Task* NewRunnableFunction(Function function, const A& a, const B& b,
	const C& c, const D& d, const E& e, const F& f,
	const G& g, const H& h)
{
	return new RunnableFunction<Function, Tuple8<A, B, C, D, E, F, G, H> >(
			function, MakeTuple(a, b, c, d, e, f, g, h));
}


}

#endif // BASE_FRAMEWORK_TASK_H_
