//
//  Runtime.swift
//  Aojet
//
//  Created by Qihe Bian on 9/22/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public typealias TimeInterval = Foundation.TimeInterval
class Runtime {
  private static let dispatcherRuntime: DispatcherRuntime =  DispatcherRuntimeProvider()
  private static let threadingRuntime: ThreadingRuntime =  ThreadingRuntimeProvider()
  private static let mainThreadRuntime: MainThreadRuntime = MainThreadRuntimeProvider()
//  private static let lifecycleRuntime: LifecycleRuntime = LifecycleRuntimeProvider()

  class func createDispatcher(name: String) -> Dispatcher {
    return threadingRuntime.createDispatcher(name: name)
  }

  class func createImmediateDispatcher(name: String, priority: ThreadPriority) -> ImmediateDispatcher {
    return threadingRuntime.createImmediateDispatcher(name: name, priority: priority)
  }

  class func actorTime() -> TimeInterval {
    return threadingRuntime.actorTime()
  }

  class func currentTime() -> TimeInterval {
    return threadingRuntime.currentTime()
  }

  class func currentSyncedTime() -> TimeInterval {
    return threadingRuntime.syncedCurrentTime()
  }

  class func createAtomicInt(initial: Int32) -> AtomicIntegerCompat {
    return threadingRuntime.createAtomicInt(value: initial)
  }

  class func createAtomicLong(initial: Int64) -> AtomicLongCompat {
    return threadingRuntime.createAtomicLong(value: initial)
  }

  class func createThreadLocal<T>() -> AnyThreadLocalCompat<T> {
    return threadingRuntime.createThreadLocal()
  }

//  class func createWeakReference<T>(val: T) -> AnyWeakReferenceCompat<T> {
//    return threadingRuntime.createWeakReference(val)
//  }

  class func coresCount() -> Int {
    return threadingRuntime.coresCount()
  }

  class func isSingleThread() -> Bool {
    return mainThreadRuntime.isSingleThread()
  }

  class func isMainThread() -> Bool {
    return mainThreadRuntime.isSingleThread() || mainThreadRuntime.isMainThread()
  }

  class func checkMainThread() {
    if RuntimeEnvironment.isProduction {
      return
    }
    if mainThreadRuntime.isSingleThread() {
      return
    }
    if !mainThreadRuntime.isMainThread() {
      fatalError("Unable to perform operation not from Main Thread")
    }
  }

  class func postToMainThread(runnable: Runnable) {
    autoreleasepool {
      mainThreadRuntime.postToMainThread(runnable: runnable)
    }
  }

  class func dispatch(runnable: Runnable) {
    autoreleasepool {
      dispatcherRuntime.dispatch(runnable: runnable)
    }
  }

  class func createLock() -> Lock {
    return threadingRuntime.createLock()
  }
}
