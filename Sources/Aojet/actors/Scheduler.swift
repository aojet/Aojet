//
//  Scheduler.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class Scheduler {

  private static let log: Bool = false
  private static let tag: String = "Scheduler"
  private static let timerDispatcher = Runtime.createDispatcher(name: "scheduler")
  var destDispatcher: Dispatcher
  var ref: ActorRef

  init(ref: ActorRef, destDispatcher: Dispatcher) {
    self.ref = ref
    self.destDispatcher = destDispatcher
  }

  convenience init(ref: ActorRef) {
    self.init(ref: ref, destDispatcher: type(of: self).timerDispatcher)
  }

  func schedule(runnable: Runnable, delay: TimeInterval) -> ActorCancellable {
    let path = ref.path
    if type(of: self).log {
      Log.debug(tag: type(of: self).tag, message: "Schedule \(path)")
    }
    let res = TaskActorCancellable()
    res.parent = self
    res.dispatchCancel = destDispatcher.dispatch(runnable: AnyRunnable {
      [weak self] in
      guard let strongSelf = self else {
        return
      }
      if res.isCancelled {
        return
      }
      strongSelf.ref.send(message: AnyRunnable {
        if res.isCancelled {
          return
        }
        runnable.run()
      })
    }, delay: delay)
    return res
  }

  private class TaskActorCancellable: ActorCancellable {
    public var objectId: Identifier

    weak var parent: Scheduler?
    private(set) var isCancelled = false
    private var _dispatchCancel: DispatchCancel? = nil
    private let lock = Runtime.createLock()
    var dispatchCancel: DispatchCancel? {
      get {
        return _dispatchCancel
      }
      set(dispatchCancel) {
        lock.lock()
        defer { lock.unlock() }
        if isCancelled && dispatchCancel != nil {
          dispatchCancel!.cancel()
        } else {
          _dispatchCancel = dispatchCancel
        }
      }
    }

    init() {
      objectId = type(of: self).generateObjectId()
    }
    
    func cancel() {
      lock.lock()
      defer { lock.unlock() }
      if !isCancelled {
        let path = parent!.ref.path
        if log {
          Log.debug(tag: Scheduler.tag, message: "Cancel \(path)")
        }
        isCancelled = true
        if dispatchCancel != nil {
          dispatchCancel!.cancel()
        }
      }
    }
  }
}
