//
//  AtomicLongCompat.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol AtomicLongCompat {

  func get() -> Int64
  func set(v: Int64)
  func incrementAndGet() -> Int64
  func getAndIncrement() -> Int64
  func decrementAndGet() -> Int64
  func getAndDecrement() -> Int64
  func compareAndSet(exp: Int64, v: Int64)

}
