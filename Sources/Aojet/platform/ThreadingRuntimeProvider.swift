//
//  ThreadingRuntimeProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/22/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class ThreadingRuntimeProvider: ThreadingRuntime {

  func actorTime() -> TimeInterval {
    return ProcessInfo.processInfo.systemUptime
  }

  func currentTime() -> TimeInterval {
    return CFAbsoluteTimeGetCurrent()
  }

  func syncedCurrentTime() -> TimeInterval {
    return currentTime()
  }

  func coresCount() -> Int {
    return ProcessInfo.processInfo.processorCount
  }
  func createAtomicInt(value: Int32) -> AtomicIntegerCompat {
    return AtomicIntegerProvider(value)
  }

  func createAtomicLong(value: Int64) -> AtomicLongCompat {
    return AtomicLongProvider(value)
  }

  func createThreadLocal<T>() -> AnyThreadLocalCompat<T> {
    return AnyThreadLocalCompat(ThreadLocalProvider<T>())
  }

//  func createWeakReference<T: AnyObject>(object: T) -> AnyWeakReferenceCompat<T> {
//    return AnyWeakReferenceCompat(GenericWeakReference(object: object))
//  }

  func createImmediateDispatcher(name: String, priority: ThreadPriority) -> ImmediateDispatcher {
    return ImmediateDispatcherProvider(name: name, priority: priority)
  }

  func createDispatcher(name: String) -> Dispatcher {
    return DispatcherProvider()
  }

  func createLock() -> Lock {
    return LockProvider()
  }
}
