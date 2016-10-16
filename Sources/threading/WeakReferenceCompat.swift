//
//  WeakReferenceCompat.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol WeakReferenceCompat {
  associatedtype T: AnyObject
  func get() -> T?
}

class AnyWeakReferenceCompat<T: AnyObject>: WeakReferenceCompat {
  private let _get: () -> (T?)

  init<S:WeakReferenceCompat>(_ base: S) where S.T == T {
    _get = base.get
  }

  func get() -> T? {
    return _get()
  }
}
