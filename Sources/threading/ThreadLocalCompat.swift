//
//  ThreadLocalCompat.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol ThreadLocalCompat: Identifiable {
  associatedtype T
  func get() -> T?
  func set(v: T)
  func remove()
}

class AnyThreadLocalCompat<T>: ThreadLocalCompat, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _get: () -> (T?)
  private let _set: (T) -> ()
  private let _remove: () -> ()

  init<S:ThreadLocalCompat>(_ base: S) where S.T == T {
    _base = base
    objectId = type(of: self).generateObjectId()
    _get = base.get
    _set = base.set
    _remove = base.remove
  }

  func get() -> T? {
    return _get()
  }

  func set(v: T) {
    _set(v)
  }

  func remove() {
    _remove()
  }
}
