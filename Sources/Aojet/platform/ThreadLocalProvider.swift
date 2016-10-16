//
//  ThreadLocalProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class ThreadLocalProvider<T>: ThreadLocalCompat {
  let objectId: Identifier
  private var currentThread: Thread {
    return Thread.current
  }

  private var key: String {
    return objectId.uuidString
  }

  init() {
    objectId = type(of: self).generateObjectId()
  }

  func get() -> T? {
    guard let boxed = currentThread.threadDictionary[key] as? Box<T> else {
      return nil
    }
    let v = boxed.value
    return v
  }

  func set(v: T) {
    let boxed = Box(value: v)
    currentThread.threadDictionary[key] = boxed
  }

  func remove() {
    currentThread.threadDictionary.removeObject(forKey: key)
  }

}

private class Box<T> {
  let value: T
  init(value: T) {
    self.value = value
  }
}
