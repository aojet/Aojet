//
//  SomeActor.swift
//  Aojet
//
//  Created by Qihe Bian on 10/20/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Aojet

class SomeActor: AskableActor {

  override func onAsk(message: Any) throws -> Promise<Any>? {
    switch message {
    case let m as AskSomething:
      return askSomething(object: m.object)
    default:
      return try super.onAsk(message: message)
    }
  }

  override func onReceive(message: Any) throws {
    switch message {
    case let m as DoSomething:
      doSomething(object: m.object)
    default:
      try super.onReceive(message: message)
    }
  }

  func doSomething(object: Any) {
    print(Thread.current)
    print("Do something with object: \(object)")
    //Do something
  }

  func askSomething(object: Any) -> Promise<Any> {
    print(Thread.current)
    print("Ask something with object: \(object)")

    return Promise(value: "A response")
  }

  struct DoSomething {
    let object: Any
  }

  struct AskSomething {
    let object: Any
  }
}
