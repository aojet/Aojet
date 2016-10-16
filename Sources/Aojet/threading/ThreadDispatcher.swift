//
//  ThreadDispatcher.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

//public enum Exception: Error {
//  case RuntimeException(reason: String)
//}

public class ThreadDispatcher {
  static var currentDispatcher: AnyThreadLocalCompat<Array<SimpleDispatcher>> = Runtime.createThreadLocal()

  public class func pushDispatcher(_ dispatcher: SimpleDispatcher) {
    if currentDispatcher.get() == nil {
      var dispatchers: Array<SimpleDispatcher> = Array()
      dispatchers.append(dispatcher)
      currentDispatcher.set(v: dispatchers)
    } else {
      var dispatchers = currentDispatcher.get()!
      dispatchers.append(dispatcher)
      currentDispatcher.set(v: dispatchers)
    }
  }

  public class func pushDispatcher(_ dispatch: @escaping (_ runnable: Runnable)->()) {
    pushDispatcher(AnySimpleDispatcher(dispatch))
  }

  public class func pushDispatcher(_ dispatch: @escaping (_ run: ()->())->()) {
    pushDispatcher(AnySimpleDispatcher(dispatch))
  }

  public class func popDispatcher() {
    var dispatchers = currentDispatcher.get()
    if dispatchers == nil || dispatchers?.count == 0 {
      fatalError("Current Thread doesn't have Active Dispatchers")
    } else {
      dispatchers?.removeLast()
      currentDispatcher.set(v: dispatchers!)
    }
  }

  public class func peekDispatcher() -> SimpleDispatcher {
    let dispatchers = currentDispatcher.get()
    if dispatchers == nil || dispatchers?.count == 0 {
      fatalError("Current Thread doesn't have Active Dispatchers")
    } else {
      return dispatchers!.last!
    }
  }

  public class func peekDispatcherOptional() -> SimpleDispatcher? {
    let dispatchers = currentDispatcher.get()
    if dispatchers == nil || dispatchers?.count == 0 {
      return nil
    } else {
      return dispatchers!.last!
    }
  }

  public class func dispatchOnCurrentThread(runnable: Runnable) {
    peekDispatcher().dispatch(runnable: runnable)
  }
}
