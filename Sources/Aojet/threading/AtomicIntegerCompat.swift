//
//  AtomicIntegerCompat.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol AtomicIntegerCompat {

  func get() -> Int32
  func set(v: Int32)
  func incrementAndGet() -> Int32
  func getAndIncrement() -> Int32
  func decrementAndGet() -> Int32
  func getAndDecrement() -> Int32
  func compareAndSet(exp: Int32, v: Int32)

}
