//
//  PromiseFunc.swift
//  Aojet
//
//  Created by Qihe Bian on 9/21/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol PromiseFunc: Identifiable {
  associatedtype R
  func exec(resolver: PromiseResolver<R>)
}

class AnyPromiseFunc<R>: PromiseFunc, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _exec: (_ resolver: PromiseResolver<R>) -> ()

  init<R1: PromiseFunc>(base: R1) where R1.R == R {
    _base = base
    objectId = base.objectId
    _exec = base.exec
  }

  init(_ exec: @escaping (_ resolver: PromiseResolver<R>) -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _exec = exec
  }

  func exec(resolver: PromiseResolver<R>) {
    _exec(resolver)
  }

}
