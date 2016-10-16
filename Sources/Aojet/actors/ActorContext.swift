//
//  ActorContext.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public class ActorContext {
  var actorScope: ActorScope

  var system: ActorSystem {
    get {
      return actorScope.actorSystem
    }
  }

  var sender: ActorRef? {
    get {
      return actorScope.sender
    }

    set(sender) {
      actorScope.sender = sender
    }
  }

  var message: Any? {
    get {
      return actorScope.message
    }

    set(message) {
      actorScope.message = message
    }
  }

  var ref: ActorRef {
    get {
      return actorScope.ref
    }
  }

  init(scope: ActorScope) {
    actorScope = scope
  }
}
