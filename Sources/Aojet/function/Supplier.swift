//
//  Supplier.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Supplier: Identifiable {
  associatedtype R
  func get() -> R
}

class AnySupplier<R>: Supplier, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _get: () -> R

  init<T: Supplier>(base: T) where T.R == R {
    _base = base
    objectId = base.objectId
    _get = base.get
  }

  init(_ get: @escaping () -> R) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _get = get
  }

  func get() -> R {
    return _get()
  }
}
