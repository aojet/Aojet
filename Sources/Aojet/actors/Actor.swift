//
//  Actor.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

open class Actor {

  private var scheduler: Scheduler! = nil
  private(set) var path: String! = nil
  private(set) var context: ActorContext! = nil
  private(set) var mailbox: Mailbox! = nil
  private var receivers: Array<Receiver>? = nil
  private var stashed: Dictionary<Int, Array<StashedMessage>>? = nil

  public var sender: ActorRef? {
    get {
      return context.sender
    }
  }

  public var ref: ActorRef {
    get {
      return context.ref
    }
  }

  public var system: ActorSystem {
    get {
      return context.system
    }
  }

  private var _dispatcher: SimpleDispatcher? = nil
  public private(set) var dispatcher: SimpleDispatcher {
    get {
      return _dispatcher!
    }
    set(dispatcher) {
      _dispatcher = dispatcher
    }
  }

  public init() {
    dispatcher = AnySimpleDispatcher {
      [weak self] (runnable: Runnable) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.ref.post(runnable: runnable)
    }
  }

  public final func initActor(path: String, context: ActorContext, mailbox: Mailbox) {
    self.path = path
    self.context = context
    self.mailbox = mailbox
  }

  public final func handle(message: Any, sender: ActorRef?) {
    internalHandle(message: message, sender: sender)
  }

  public final func stash() {
    stash(at: 0)
  }

  public final func stash(at index:Int) {
    if stashed == nil {
      stashed = Dictionary()
    }
    var stashedMessages = stashed![index]
    if stashedMessages == nil {
      stashedMessages = Array()
      stashed![index] = stashedMessages
    }
    stashedMessages!.append(StashedMessage(message: context.message, sender: context.sender))
  }

  public final func unstashAll() {
    unstashAll(at: 0)
  }

  public final func unstashAll(at index: Int) {
    if stashed == nil {
      return
    }
    var stashedMessages = stashed![index]
    if stashedMessages == nil || stashedMessages!.count == 0 {
      return
    }
    for stashedMessage in stashedMessages!.reversed() {
      ref.sendFirst(message: stashedMessage.message, sender: stashedMessage.sender)
    }
    stashedMessages!.removeAll()
  }

  public final func become(receiver: Receiver) {
    if receivers == nil {
      receivers = Array()
    }
    receivers!.append(receiver)
  }

  public final func become(receiver: @escaping (_ message: Any) -> ()) {
    become(receiver: AnyReceiver(receiver))
  }

  public final func unbecome() {
    if receivers == nil {
      receivers = Array()
    }
    if !receivers!.isEmpty {
      receivers!.removeLast()
    }
  }

  private func internalHandle(message: Any, sender: ActorRef?) {
    ThreadDispatcher.pushDispatcher(dispatcher)
    context.sender = sender
    context.message = message
    do {
      defer {
        ThreadDispatcher.popDispatcher()
        context.sender = nil
        context.message = nil
      }
      do {
        if receivers != nil && receivers!.count > 0 {
          try receivers!.last!.onReceive(message: message)
          return
        }
        switch message {
        case let r as Runnable:
          r.run()
        default:
          try onReceive(message: message)
        }
      } catch _ {
        
      }
    }
  }

  open func preStart() throws {

  }

  open func onReceive(message: Any) throws {
    drop(message: message)
  }

  open func postStop() throws {

  }

  public func reply(message: Any) {
    if context.sender != nil {
      context.sender!.send(message: message, sender: ref)
    }
  }

  public func drop(message: Any) {
    if system.traceInterface != nil {
      system.traceInterface!.onDrop(sender: sender, message: message, actor: self)
    }
    reply(message: DeadLetter(message: message))
  }

  public func forward(dest: ActorRef) {
    dest.send(message: context.message, sender: context.sender)
  }

  public func halt(message: String) throws {
    try halt(message: message, error: nil)
  }

  public func halt(message: String, error: Error?) throws {
    throw RuntimeException.actorHalter(message: message, nestedError: error)
  }

  func schedule(obj: Any, delay: TimeInterval) -> ActorCancellable? {
    if scheduler == nil {
      scheduler = Scheduler(ref: ref)
    }
    switch obj {
    case let r as Runnable:
      return scheduler.schedule(runnable: r, delay: delay)
    default:
      return scheduler.schedule(runnable: AnyRunnable { [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.handle(message: obj, sender: strongSelf.ref)
      }, delay: delay)
    }
  }
}
