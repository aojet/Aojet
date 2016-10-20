//
//  ActorSystem.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public class ActorSystem {
  public static let threadMultiplier: Float = 1.5
  public static let threadMaxCount: Int = 4
  private static let defaultDispatcher = "default"
  public static let system = ActorSystem()

//  public static func system() -> ActorSystem {
//    return mainSystem
//  }

  final var dispatchers: Dictionary<String, ActorDispatcher> = Dictionary()
  private let dispatchersLock = Runtime.createLock()
  public var traceInterface: TraceInterface?

  public convenience init() {
    self.init(addDefaultDispatcher: true)
  }

  public init(addDefaultDispatcher: Bool) {
    if addDefaultDispatcher {
      addDispatcher(dispatcherId: type(of: self).defaultDispatcher)
    }
  }

  public func addDispatcher(dispatcherId: String, threadsCount: Int) {
    dispatchersLock.lock()
    defer { dispatchersLock.unlock() }
    if dispatchers.contains(where: { (key, obj) -> Bool in
      return key == dispatcherId
    }) {
      return
    }
    let dispatcher: ActorDispatcher = ActorDispatcher(name: dispatcherId, priority: .low, actorSystem: self, dispatchersCount: Runtime.isSingleThread() ? 1 : threadsCount)
    dispatchers[dispatcherId] = dispatcher
  }

  public func addDispatcher(dispatcherId: String) {
    addDispatcher(dispatcherId: dispatcherId, threadsCount: min(Int(Float(Runtime.coresCount())*type(of: self).threadMultiplier), type(of: self).threadMaxCount))
  }

  public func actorOf(selection: ActorSelection) throws -> ActorRef {
    return try actorOf(props: selection.props, path: selection.path)
  }

  public func actorOf(props: Props, path: String) throws -> ActorRef {
    let dispatcherId = props.dispatcher == nil ? type(of: self).defaultDispatcher : props.dispatcher
    var mailboxesDispatcher: ActorDispatcher
    dispatchersLock.lock()
    if !dispatchers.contains(where: { (key, obj) -> Bool in
      return key == dispatcherId
    }) {
      throw RuntimeException.general(message: "Unknown dispatcherId '\(dispatcherId!)'")
    }
    mailboxesDispatcher = dispatchers[dispatcherId!]!
    dispatchersLock.unlock()
    return mailboxesDispatcher.referenceActor(path: path, props: props)
  }

  public func actorOf(path: String, props: Props) throws -> ActorRef {
    return try actorOf(props: props, path: path)
  }

  public func actorOf(path: String, creator: ActorCreator) throws -> ActorRef {
    return try actorOf(props: Props.create(creator: creator), path: path)
  }

  public func actorOf(path: String, creator: ActorCreator, supervisor: ActorSupervisor) throws -> ActorRef {
    return try actorOf(props: Props.create(creator: creator).changeSupervisor(supervisor: supervisor), path: path)
  }

  public func actorOf(path: String, dispatcher: String, creator: ActorCreator) throws -> ActorRef {
    return try actorOf(props: Props.create(creator: creator).changeDispatcher(dispatcher: dispatcher), path: path)
  }

  public func actorOf(path: String, dispatcher: String, creator: ActorCreator, supervisor: ActorSupervisor) throws -> ActorRef {
    return try actorOf(props: Props.create(creator: creator).changeDispatcher(dispatcher: dispatcher).changeSupervisor(supervisor: supervisor), path: path)
  }

  public func actorOf<T:Actor>(path: String, dispatcher: String, constructor: AnyConstructor<T>) throws -> ActorRef {
    return try actorOf(props: Props.create(creator: AnyActorCreator({actor in
      return constructor.create()
    })).changeDispatcher(dispatcher: dispatcher), path: path)
  }

}
