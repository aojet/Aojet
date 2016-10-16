//
//  AskableActor.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

open class AskableActor: Actor {
  open func onAsk(message: Any) throws -> Promise<Any>? {
    throw RuntimeException.general(message: "Not implemented")
  }

  override open func onReceive(message: Any) throws {
    switch message {
    case let askRequest as AskInternalRequest:
      do {
        let p = try onAsk(message: askRequest.message)
        if p == nil {
          return
        }
        p!.pipeTo(resolver: askRequest.future)
      } catch let e {
        print(Thread.callStackSymbols)
        askRequest.future.tryError(e)
      }
    default:
      try super.onReceive(message: message)
    }
  }
}

public extension ActorRef {
  public func ask<T>(message: Any) -> Promise<T> {
    return ask(message: message, sender: nil)
  }

  public func ask<T>(message: Any, sender: ActorRef?) -> Promise<T> {
    return Promise<Any>(executor: AnyPromiseFunc { (executor) in
      self.send(message: AskInternalRequest(message: message, future: executor), sender: sender)
    }).map { (r) -> T? in
      return r as? T
    }
  }

  public func ask<T>(message: AskMessage<T>) -> Promise<T> {
    return ask(message: message, sender: nil)
  }
  
  public func ask<T>(message: AskMessage<T>, sender: ActorRef?) -> Promise<T> {
    return ask(message: message as Any, sender: sender)
  }

  public func kill() {
    self.send(message: PoisonPill.instance)
  }
}
