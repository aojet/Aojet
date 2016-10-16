//
//  ThreadingRuntime.swift
//  Aojet
//
//  Created by Qihe Bian on 9/22/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol ThreadingRuntime {
  func actorTime() -> TimeInterval
  func currentTime() -> TimeInterval
  func syncedCurrentTime() -> TimeInterval
  func coresCount() -> Int
  func createAtomicInt(value: Int32) -> AtomicIntegerCompat
  func createAtomicLong(value: Int64) -> AtomicLongCompat
  func createThreadLocal<T>() -> AnyThreadLocalCompat<T>
//  func createWeakReference<T: AnyObject>(val: T) -> AnyWeakReferenceCompat<T>
  func createDispatcher(name: String) -> Dispatcher
  func createImmediateDispatcher(name: String, priority: ThreadPriority) -> ImmediateDispatcher
  func createLock() -> Lock
}
