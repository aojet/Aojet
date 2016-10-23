//
//  Promise.swift
//  Aojet
//
//  Created by Qihe Bian on 9/21/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public class Promise<R> {
  public static func success(value: R) -> Promise<R> {
    return Promise(value: value)
  }

  public static func failure(error: Error) -> Promise<R> {
    return Promise(error: error)
  }

  private var callbacks: Array<AnyPromiseCallback<R>> = Array()
  private let dispatcher: SimpleDispatcher?

  private var result: R?
  private var error: Error?
  private var isFinished: Bool = false

  private let lock = Runtime.createLock()

  init(executor: AnyPromiseFunc<R>) {
    dispatcher = ThreadDispatcher.peekDispatcherOptional()
    executor.exec(resolver: PromiseResolver(promise: self))
  }

  init(executor: AnyPromiseFunc<R>, dispatcher: SimpleDispatcher) {
    self.dispatcher = dispatcher
    executor.exec(resolver: PromiseResolver(promise: self))
  }

  public convenience init(executor: @escaping (_ resolver: PromiseResolver<R>) -> ()) {
    self.init(executor: AnyPromiseFunc(executor))
  }

  public init(value: R) {
    dispatcher = ThreadDispatcher.peekDispatcherOptional()
    result = value
    error = nil
    isFinished = true
  }

  public init(error: Error) {
    dispatcher = ThreadDispatcher.peekDispatcherOptional()
    result = nil
    self.error = error
    isFinished = true
  }

  @discardableResult
  func then(_ then: AnyConsumer<R>) -> Promise<R> {
    lock.lock()
    defer { lock.unlock() }
    if isFinished {
      if error == nil {
        if dispatcher != nil {
          dispatcher!.dispatch(runnable: AnyRunnable {
            try! then.apply(self.result!)
          })
        } else {
          try! then.apply(result!)
        }
      }
    } else {
      callbacks.append(AnyPromiseCallback(onResult: { (res) in
        if self.dispatcher != nil {
          self.dispatcher!.dispatch(runnable: AnyRunnable {
            try! then.apply(res)
          })
        } else {
          try! then.apply(res)
        }
        }, onError: { (e) in
          //Do nothing
      }))
    }
    return self
  }

  @discardableResult
  public func then(_ closure: @escaping (R) -> ()) -> Promise<R> {
    return then(AnyConsumer(closure))
  }

  @discardableResult
  func failure(_ failure: AnyConsumer<Error>) -> Promise<R> {
    lock.lock()
    defer { lock.unlock() }
    if isFinished {
      if error != nil {
        if dispatcher != nil {
          dispatcher!.dispatch(runnable: AnyRunnable {
            try! failure.apply(self.error!)
          })
        } else {
          try! failure.apply(error!)
        }
      }
    } else {
      callbacks.append(AnyPromiseCallback(onResult: { (res) in
        //Do nothing
        }, onError: { (e) in
          try! failure.apply(e)
      }))
    }
    return self
  }

  @discardableResult
  public func failure(_ closure: @escaping (Error) -> ()) -> Promise<R> {
    return failure(AnyConsumer(closure))
  }

  public func error(_ e: Error) {
    try! _error(e)
  }

  private func _error(_ e: Error) throws {
    lock.lock()
    defer { lock.unlock() }
    if isFinished {
      throw RuntimeException.general(message: "Promise \(String(describing: self)) already completed!")
    }

    isFinished = true
    error = e
    deliverResult()
  }

  public func tryError(_ e: Error) {
    lock.lock()
    defer { lock.unlock() }
    if isFinished {
      return
    }
    error(e)
  }

  public func result(_ res: R?) {
    try! _result(res)
  }

  private func _result(_ res: R?) throws {
    lock.lock()
    defer { lock.unlock() }
    if isFinished {
      throw RuntimeException.general(message: "Promise \(String(describing: self)) already completed!")
    }
    isFinished = true
    result = res
    deliverResult()
  }

  public func tryResult(_ res: R?) {
    lock.lock()
    defer { lock.unlock() }
    if isFinished {
      return
    }
    result(res)
  }

  func deliverResult() {
    if callbacks.count > 0 {
      if dispatcher != nil {
        dispatcher!.dispatch(runnable: AnyRunnable {
          self.invokeDeliver()
        })
      } else {
        invokeDeliver()
      }
    }
  }

  func invokeDeliver() {
    if error != nil {
      for callback in callbacks {
        callback.onError(e: error!)
      }
    } else {
      for callback in callbacks {
        callback.onResult(t: result!)
      }
    }
    callbacks.removeAll()
  }

  func map<R1>(_ func: AnyFunction<R, R1>) -> Promise<R1> {
    return Promise<R1>(executor: AnyPromiseFunc { [weak self] (resolver) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.then(AnyConsumer<R> { (t) in
        let r = `func`.apply(t)
        resolver.tryResult(r)
      })
      strongSelf.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    })
  }

  public func map<R1>(_ closure: @escaping (R) -> R1) -> Promise<R1> {
    return map(AnyFunction(closure))
  }

  public func changeDispatcher(_ dispatcher: SimpleDispatcher) -> Promise<R> {
    return Promise<R>(executor: AnyPromiseFunc { [weak self] (resolver) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.then(AnyConsumer<R> { (t) in
        resolver.tryResult(t)
      })
      strongSelf.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    }, dispatcher: dispatcher)
  }

  public func changeDispatcher(_ dispatch: @escaping (_ runnable: Runnable)->()) -> Promise<R> {
    return changeDispatcher(AnySimpleDispatcher(dispatch))
  }

  public func changeDispatcher(_ dispatch: @escaping (_ run: ()->())->()) -> Promise<R> {
    return changeDispatcher(AnySimpleDispatcher(dispatch))
  }

  func flatMap<R1>(_ func: AnyFunction<R, Promise<R1>>) -> Promise<R1> {
    return Promise<R1>(executor: AnyPromiseFunc { [weak self] (resolver) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.then(AnyConsumer<R> { (t) in
        let promise = `func`.apply(t)
        promise.then(AnyConsumer { (t2) in
          resolver.result(t2)
        })
        promise.failure(AnyConsumer { (e) in
          resolver.error(e)
        })
      })
      strongSelf.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    })
  }

  public func flatMap<R1>(_ closure: @escaping (R) -> (Promise<R1>)) -> Promise<R1> {
    return flatMap(AnyFunction(closure))
  }

  func chain<R1>(_ func: AnyFunction<R, Promise<R1>>) -> Promise<R> {
    return Promise<R>(executor: AnyPromiseFunc { [weak self] (resolver) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.then(AnyConsumer<R> { (t) in
        let chained = `func`.apply(t)
        chained.then(AnyConsumer { (t2) in
          resolver.result(t)
        })
        chained.failure(AnyConsumer { (e) in
          resolver.error(e)
        })
      })
      strongSelf.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    })
  }

  public func chain<R1>(_ closure: @escaping (R) -> (Promise<R1>)) -> Promise<R> {
    return chain(AnyFunction(closure))
  }

  @discardableResult
  func after(afterHandler: AnyConsumerDouble<R?, Error?>) -> Promise<R> {
    then(AnyConsumer { (t) in
      try! afterHandler.apply(t, nil)
    })
    failure(AnyConsumer { (e) in
      try! afterHandler.apply(nil, e)
    })
    return self
  }

  @discardableResult
  public func after(afterHandler: @escaping (R?, Error?) -> ()) -> Promise<R> {
    return after(afterHandler: AnyConsumerDouble(afterHandler))
  }

  @discardableResult
  public func pipeTo(resolver: PromiseResolver<R>) -> Promise<R> {
    then(AnyConsumer { (t) in
      resolver.result(t)
    })
    failure(AnyConsumer { (e) in
      resolver.error(e)
    })
    return self
  }

  @discardableResult
  func fallback(catchThen: AnyFunction<Error, Promise<R>>) -> Promise<R> {
    return Promise<R>(executor: AnyPromiseFunc { [weak self] (resolver) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.then(AnyConsumer<R> { (r) in
          resolver.result(r)
      })
      strongSelf.failure(AnyConsumer { (e) in
        let res = catchThen.apply(e)
        res.then(AnyConsumer { (t) in
          resolver.result(t)
        })
        res.failure(AnyConsumer { (e2) in
          resolver.error(e2)
        })
      })
    })
  }

  @discardableResult
  public func fallback(catchThen: @escaping (Error) -> Promise<R>) -> Promise<R> {
    return fallback(catchThen: AnyFunction(catchThen))
  }

  func mapIfNull(producer: AnySupplier<R>) -> Promise<R> {
    return Promise<R>(executor: AnyPromiseFunc { (resolver) in
      self.then(AnyConsumer { (t) in
        var r = t
        if r is ExpressibleByNilLiteral && r as? ExpressibleByNilLiteral == nil {
          r = producer.get()
          resolver.result(r)
        } else {
          resolver.result(r)
        }
      })
      self.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    })
  }

  public func mapIfNull(_ closure: @escaping () -> R) -> Promise<R> {
    return mapIfNull(producer: AnySupplier(closure))
  }

  func mapIfNullPromise(producer: AnySupplier<Promise<R>>) -> Promise<R> {
    return Promise<R>(executor: AnyPromiseFunc { (resolver) in
      self.then(AnyConsumer { (t) in
        if t is ExpressibleByNilLiteral && t as? ExpressibleByNilLiteral == nil {
          let promise = producer.get()
          promise.then(AnyConsumer { (t2) in
            resolver.result(t2)
          })
          promise.failure(AnyConsumer { (e) in
            resolver.error(e)
          })
        } else {
          resolver.result(t)
        }
      })
      self.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    })
  }

  public func mapIfNullPromise(_ closure: @escaping () -> Promise<R>) -> Promise<R> {
    return mapIfNullPromise(producer: AnySupplier(closure))
  }

  @discardableResult
  func log(tag: String) -> Promise<R> {
    then(AnyConsumer { (t) in
      Log.debug(tag: tag, message: "Result: \(t)")
    })
    failure(AnyConsumer { (e) in
      Log.warning(tag: tag, message: "Error: \(e)")
    })
    return self
  }
}

protocol PromiseCallback: Identifiable {
  associatedtype R
  func onResult(t: R)
  func onError(e: Error)
}

class AnyPromiseCallback<R>: PromiseCallback, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _onResult: (_ t: R) -> ()
  private let _onError: (_ e: Error) -> ()

  init<R1: PromiseCallback>(base: R1) where R1.R == R {
    _base = base
    objectId = base.objectId
    _onResult = base.onResult
    _onError = base.onError
  }

  init(onResult: @escaping (_ t: R)->(), onError: @escaping (_ e: Error) -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _onResult = onResult
    _onError = onError
  }

  func onResult(t: R) {
    _onResult(t)
  }

  func onError(e: Error) {
    _onError(e)
  }

}
