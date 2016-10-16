//
//  Predicate.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/6.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Predicate: Identifiable {
  associatedtype A
  func apply(_ a: A) -> Bool
}

class AnyPredicate<A>: Predicate, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _apply: (_ a: A) -> Bool

  init<T: Predicate>(base: T) where T.A == A {
    _base = base
    objectId = base.objectId
    _apply = base.apply
  }

  init(_ apply: @escaping (_ a: A)->Bool) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _apply = apply
  }

  func apply(_ a: A) -> Bool {
    return _apply(a)
  }
}
//
//class Predicates<T> {
//  static let null = AnyPredicate { (o) in
//    return o == nil
//  }
//
//  static let notNull = AnyPredicate { (o) in
//    return o != nil
//  }
//}
