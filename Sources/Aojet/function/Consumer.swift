//
//  Consumer.swift
//  Aojet
//
//  Created by Qihe Bian on 6/8/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Consumer: Identifiable {
  associatedtype A
  func apply(_ a: A) throws
}

class AnyConsumer<A>: Consumer, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _apply: (_ a: A) throws -> ()

  init<T: Consumer>(base: T) where T.A == A {
    _base = base
    objectId = base.objectId
    _apply = base.apply
  }

  init(_ apply: @escaping (_ a: A) throws -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _apply = apply
  }

  func apply(_ a: A) throws {
    try _apply(a)
  }
}

typealias FuncConsumerDouble<A, B> = (_ a: A, _ b: B) -> ()
protocol ConsumerDouble: Identifiable {
  associatedtype A
  associatedtype B
  func apply(_ a: A, _ b: B) throws
}

class AnyConsumerDouble<A, B>: ConsumerDouble, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _apply: (_ a: A, _ b: B) throws -> ()

  init<T: ConsumerDouble>(base: T) where T.A == A, T.B == B {
    _base = base
    objectId = base.objectId
    _apply = base.apply
  }

  init(_ apply: @escaping (_ a: A, _ b: B) throws -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _apply = apply
  }

  func apply(_ a: A, _ b: B) throws {
    try _apply(a, b)
  }
}
