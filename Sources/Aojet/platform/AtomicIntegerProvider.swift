//
//  AtomicIntegerProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class AtomicIntegerProvider: AtomicIntegerCompat {
  private (set) var value: Int32 = 0

  init(_ v: Int32) {
    value = v
  }

  func get() -> Int32 {
    return value
  }

  func set(v: Int32) {
    value = v
  }

  func incrementAndGet() -> Int32 {
    return OSAtomicIncrement32(&value)
  }

  func getAndIncrement() -> Int32 {
    return OSAtomicIncrement32(&value)-1
  }

  func decrementAndGet() -> Int32 {
    return OSAtomicDecrement32(&value)
  }

  func getAndDecrement() -> Int32 {
    return OSAtomicDecrement32(&value)+1
  }

  func compareAndSet(exp: Int32, v: Int32) {
    OSAtomicCompareAndSwap32(exp, v, &value)
  }

}
