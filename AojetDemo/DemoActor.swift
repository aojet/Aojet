//
//  DemoActor.swift
//  Aojet
//
//  Created by Qihe Bian on 10/7/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Aojet

class DemoActor: AskableActor {

  class func create() -> ActorRef {
    return try! ActorSystem.system.actorOf(path: "demo", props: Props.create(creator: AnyActorCreator { () -> Actor in
      return DemoActor()
    }))
  }

  override init() {
//    super.init()
    print("DemoActor init")
  }

  override func preStart() {
    ref.send(message: InitActor())
  }

  override func postStop() {

  }

  override func onReceive(message: Any) {
    switch message {
    case is InitActor:
      initActor()
    case is StopActor:
      stopActor()
    default:
      try! super.onReceive(message: message)
    }
  }

  override func onAsk(message: Any) throws -> Promise<Any>? {
    switch message {
    case is InitActor:
      return Promise(value: "InitActor")
    case is StopActor:
      return Promise(value: "StopActor")
    default:
      return Promise(value: nil)
    }
  }

  func initActor() {
    print("initActor")
  }

  func stopActor() {
    ref.send(message: PoisonPill.instance)
    print("stopActor")
  }

  struct InitActor {

  }

  struct StopActor {

  }

}
