//
//  Function.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Function: Identifiable {
  associatedtype A
  associatedtype R

  func apply(_ a: A) -> R
}

class AnyFunction<A, R>: Function, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _apply: (_ a: A) -> R

  init<T: Function>(base: T) where T.A == A, T.R == R {
    _base = base
    objectId = base.objectId
    _apply = base.apply
  }

  init(_ apply: @escaping (_ a: A) -> R) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _apply = apply
  }

  func apply(_ a: A) -> R {
    return _apply(a)
  }
}
