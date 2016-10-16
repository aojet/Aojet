//
//  AtomicLongProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class AtomicLongProvider: AtomicLongCompat {
  private (set) var value: Int64 = 0

  init(_ v: Int64) {
    value = v
  }

  func get() -> Int64 {
    return value
  }

  func set(v: Int64) {
    value = v
  }

  func incrementAndGet() -> Int64 {
    return OSAtomicIncrement64(&value)
  }

  func getAndIncrement() -> Int64 {
    return OSAtomicIncrement64(&value)-1
  }

  func decrementAndGet() -> Int64 {
    return OSAtomicDecrement64(&value)
  }

  func getAndDecrement() -> Int64 {
    return OSAtomicDecrement64(&value)+1
  }

  func compareAndSet(exp: Int64, v: Int64) {
    OSAtomicCompareAndSwap64(exp, v, &value)
  }
}
