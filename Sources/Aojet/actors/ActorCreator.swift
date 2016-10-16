//
//  ActorCreator.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public protocol ActorCreator: Identifiable {
  func create() throws -> Actor
}

public final class AnyActorCreator: ActorCreator, IdentifierHashable {
  private let _base: Any?
  public let objectId: Identifier
  private let _create: () throws -> Actor

  public init<T: ActorCreator>(_ base: T) {
    _base = base
    objectId = base.objectId
    _create = base.create
  }

  public init(_ closure: @escaping () throws -> Actor) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _create = closure
  }

  public func create() throws -> Actor {
    return try _create()
  }
}
