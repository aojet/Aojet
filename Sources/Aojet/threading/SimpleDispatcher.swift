//
//  SimpleDispatcher.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public protocol SimpleDispatcher {

  func dispatch(runnable: Runnable)
  func dispatch(run: ()->())

}

public extension SimpleDispatcher {
  func dispatch(runnable: Runnable) {

  }

  func dispatch(run: @escaping ()->()) {
    dispatch(runnable: AnyRunnable(run))
  }
}

public final class AnySimpleDispatcher: SimpleDispatcher {
  private let _dispatch: ((Runnable) -> ())?
  private let _dispatch2: ((()->()) -> ())?

  public init<T:SimpleDispatcher>(_ base: T) {
    _dispatch = base.dispatch
    _dispatch2 = base.dispatch
  }

  public init(_ closure:@escaping (Runnable)->()) {
    _dispatch = closure
    _dispatch2 = nil
  }

  public init(_ closure:@escaping (()->())->()) {
    _dispatch2 = closure
    _dispatch = nil
  }

  public func dispatch(runnable: Runnable) {
    if _dispatch != nil {
      _dispatch!(runnable)
    }
  }

  public func dispatch(run: ()->()) {
    if _dispatch2 != nil {
      _dispatch2!(run)
    }
  }

}
