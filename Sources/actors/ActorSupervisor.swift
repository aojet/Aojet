//
//  ActorSupervisor.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public protocol ActorSupervisor: Identifiable {
  func onActorStopped(ref: ActorRef)
}

public final class AnyActorSupervisor: ActorSupervisor, IdentifierHashable {
  private let _base: Any?
  public let objectId: Identifier
  private let _onActorStopped: (_ ref: ActorRef) -> ()

  public init<T: ActorSupervisor>(_ base: T) {
    _base = base
    objectId = base.objectId
    _onActorStopped = base.onActorStopped
  }

  public init(_ closure: @escaping (_ ref: ActorRef) -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _onActorStopped = closure
  }

  public func onActorStopped(ref: ActorRef) {
    _onActorStopped(ref)
  }
}
