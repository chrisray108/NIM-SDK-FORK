// Copyright (c) 2011, NetEase Inc. All rights reserved.
//
// Author: Ruan Liang <ruanliang@corp.netease.com>
// Date: 2011/6/29
//
// Scopers help you manage ownership of a pointer, helping you easily manage the
// a pointer within a scope, and automatically destroying the pointer at the
// end of a scope.  There are two main classes you will use, which correspond
// to the operators new/delete and new[]/delete[].
//               
// Example usage (scoped_ptr):
// {
//     scoped_ptr<Foo> foo(new Foo("wee"));
// }  // foo goes out of scope, releasing the pointer with it.
//               
// {
//     scoped_ptr<Foo> foo;          // No pointer managed.
//     foo.reset(new Foo("wee"));    // Now a pointer is managed.
//     foo.reset(new Foo("wee2"));   // Foo("wee") was destroyed.
//     foo.reset(new Foo("wee3"));   // Foo("wee2") was destroyed.
//     foo->Method();                // Foo::Method() called.
//     foo.get()->Method();          // Foo::Method() called.
//     SomeFunc(foo.release());      // SomeFunc takes ownership, foo no longer
//                                 // manages a pointer.
//     foo.reset(new Foo("wee4"));   // foo manages a pointer again.
//     foo.reset();                  // Foo("wee4") destroyed, foo no longer
//                                 // manages a pointer.
// }  // foo wasn't managing a pointer, so nothing was destroyed.
//               
// Example usage (scoped_array):
// {
//     scoped_array<Foo> foo(new Foo[100]);
//     foo.get()->Method();  // Foo::Method on the 0th element.
//     foo[10].Method();     // Foo::Method on the 10th element.
// }

#ifndef BASE_MEMORY_SCOPED_PTR_H_
#define BASE_MEMORY_SCOPED_PTR_H_

#include <assert.h>
#include "base/base_types.h"

namespace nbase
{

// A scoped_ptr<T> is like a T*, except that the destructor of scoped_ptr<T>
// automatically deletes the pointer it holds (if any).
// That is, scoped_ptr<T> owns the T object that it points to.
// Like a T*, a scoped_ptr<T> may hold either NULL or a pointer to a T object.
// Also like T*, scoped_ptr<T> is thread-compatible, and once you
// dereference it, you get the threadsafety guarantees of T.
//
// The size of a scoped_ptr is small:
// sizeof(scoped_ptr<T>) == sizeof(T*)
template <class T>
class scoped_ptr
{
public:

	// The element type
	typedef T element_type;

	// Constructor.  Defaults to initializing with NULL.
	// There is no way to create an uninitialized scoped_ptr.
	// The input parameter must be allocated with new.
	explicit scoped_ptr(T *p = NULL) : ptr_(p) { }

	// Destructor.  If there is a C object, delete it.
	// We don't need to test ptr_ == NULL because C++ does that for us.
	~scoped_ptr()
	{
		enum { type_must_be_complete = sizeof(T) };
		delete ptr_;
	}

	// Reset.  Deletes the current owned object, if any.
	// Then takes ownership of a new object, if given.
	// this->reset(this->get()) works.
	void reset(T *p = NULL)
	{
		if (p != ptr_)
		{
			enum { type_must_be_complete = sizeof(T) };
			delete ptr_;
			ptr_ = p;
		}
	}

	// Accessors to get the owned object.
	// operator* and operator-> will assert() if there is no current object.
	T& operator*() const
	{
		assert(ptr_ != NULL);
		return *ptr_;
	}
	T* operator->() const
	{
		assert(ptr_ != NULL);
		return ptr_;
	}
	T* get() const { return ptr_; }

	// Comparison operators.
	// These return whether two scoped_ptr refer to the same object, not just to
	// two different but equal objects.
	bool operator==(T *p) const { return ptr_ == p; }
	bool operator!=(T *p) const { return ptr_ != p; }

	// Swap two scoped pointers.
	void swap(scoped_ptr &p2)
	{
		T *tmp  = ptr_;
		ptr_    = p2.ptr_;
		p2.ptr_ = tmp;
	}

	// Release a pointer.
	// The return value is the current pointer held by this object.
	// If this object holds a NULL pointer, the return value is NULL.
	// After this operation, this object will hold a NULL pointer,
	// and will not own the object any more.
	T* release()
	{
		T *retVal = ptr_;
		ptr_      = NULL;
		return retVal;
	}

private:
	T *ptr_;

	// Forbid comparison of scoped_ptr types.  If T2 != C, it totally doesn't
	// make sense, and if T2 == C, it still doesn't make sense because you should
	// never have the same object owned by two different scoped_ptrs.
	template <class T2> bool operator==(scoped_ptr<T2> const& p2) const;
	template <class T2> bool operator!=(scoped_ptr<T2> const& p2) const;

	// Disallow evil constructors
	scoped_ptr(const scoped_ptr&);
	void operator=(const scoped_ptr&);
};

// Free functions
template <class T>
void swap(scoped_ptr<T> &p1, scoped_ptr<T> &p2)
{
	p1.swap(p2);
}

template <class T>
bool operator==(T *p1, const scoped_ptr<T> &p2)
{
	return p1 == p2.get();
}

template <class T>
bool operator!=(T *p1, const scoped_ptr<T> &p2)
{
	return p1 != p2.get();
}


// scoped_array<T> is like scoped_ptr<T>, except that the caller must allocate
// with new [] and the destructor deletes objects with delete [].
//
// As with scoped_ptr<T>, a scoped_array<T> either points to an object
// or is NULL.  A scoped_array<T> owns the object that it points to.
// scoped_array<T> is thread-compatible, and once you index into it,
// the returned objects have only the threadsafety guarantees of T.
//
// Size: sizeof(scoped_array<T>) == sizeof(T*)
template <class T>
class scoped_array
{
public:

	// The element type
	typedef T element_type;

	// Constructor.  Defaults to intializing with NULL.
	// There is no way to create an uninitialized scoped_array.
	// The input parameter must be allocated with new [].
	explicit scoped_array(T *p = NULL) : array_(p) { }

	// Destructor.  If there is a C object, delete it.
	// We don't need to test ptr_ == NULL because C++ does that for us.
	~scoped_array()
	{
		enum { type_must_be_complete = sizeof(T) };
		delete[] array_;
	}

	// Reset.  Deletes the current owned object, if any.
	// Then takes ownership of a new object, if given.
	// this->reset(this->get()) works.
	void reset(T *p = NULL)
	{
		if (p != array_)
		{
			enum { type_must_be_complete = sizeof(T) };
			delete[] array_;
			array_ = p;
		}
	}

	// Get one element of the current object.
	// Will assert() if there is no current object, or index i is negative.
	T& operator[](int64_t i) const
	{
		assert(i >= 0);
		assert(array_ != NULL);
		return array_[i];
	}

	// Get a pointer to the zeroth element of the current object.
	// If there is no current object, return NULL.
	T* get() const
	{
		return array_;
	}

	// Comparison operators.
	// These return whether two scoped_array refer to the same object, not just to
	// two different but equal objects.
	bool operator==(T *p) const { return array_ == p; }
	bool operator!=(T *p) const { return array_ != p; }

	// Swap two scoped arrays.
	void swap(scoped_array &p2)
	{
		T *tmp = array_;
		array_ = p2.array_;
		p2.array_ = tmp;
	}

	// Release an array.
	// The return value is the current pointer held by this object.
	// If this object holds a NULL pointer, the return value is NULL.
	// After this operation, this object will hold a NULL pointer,
	// and will not own the object any more.
	T* release()
	{
		T *retVal = array_;
		array_ = NULL;
		return retVal;
	}

private:
	T *array_;

	// Forbid comparison of different scoped_array types.
	template <class T2> bool operator==(scoped_array<T2> const &p2) const;
	template <class T2> bool operator!=(scoped_array<T2> const &p2) const;

	// Disallow evil constructors
	scoped_array(const scoped_array&);
	void operator=(const scoped_array&);
};

// Free functions
template <class T>
void swap(scoped_array<T> &p1, scoped_array<T> &p2)
{
	p1.swap(p2);
}

template <class T>
bool operator==(T *p1, const scoped_array<T> &p2)
{
	return p1 == p2.get();
}

template <class T>
bool operator!=(T *p1, const scoped_array<T> &p2)
{
	return p1 != p2.get();
}


}  // namespace nbase

#endif  // BASE_MEMORY_SCOPED_PTR_H_