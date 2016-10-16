//
//  Constructor.swift
//  Aojet
//
//  Created by Qihe Bian on 6/10/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public protocol Constructor: Identifiable {
  associatedtype T
  func create() -> T
}

public class AnyConstructor<T>: Constructor, IdentifierHashable {
  private let _base: Any?
  public let objectId: Identifier
  private let _create: () -> T

  public init<S: Constructor>(_ base: S) where S.T == T {
    _base = base
    objectId = base.objectId
    _create = base.create
  }

  public init(_ closure: @escaping () -> T) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _create = closure
  }

  public func create() -> T {
    return _create()
  }
}
