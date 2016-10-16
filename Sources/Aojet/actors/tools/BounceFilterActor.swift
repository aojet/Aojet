//
//  BounceFilterActor.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class BounceFilterActor: Actor {
  static let bounceDelay: TimeInterval = 0.3
  var lastMessage: TimeInterval = 0
  var message: Message?
  var flushCancellable: ActorCancellable?

  func onMessage(message: Message) {
    let time = ActorTime.currentTime()
    let delta = time - lastMessage
    if (delta > type(of: self).bounceDelay) {
      lastMessage = time;
      if self.message == nil || isOverride(current: self.message, next: message) {
        // Send message
        message.actorRef.send(message: message.object);
      } else {
        // Send old message
        self.message!.actorRef.send(message: self.message!.object);
      }
      self.message = nil;
    } else {
      // Too early
      if (self.message == nil || isOverride(current: self.message, next: message)) {
        self.message = message;
        if (flushCancellable != nil) {
          flushCancellable!.cancel();
          flushCancellable = nil;
        }
        flushCancellable = schedule(obj: Flush(), delay: type(of: self).bounceDelay - delta);
      }
    }
  }

  func onFlush() {
    if (message != nil) {
      message!.actorRef.send(message: message!.object);
      message = nil;
      lastMessage = ActorTime.currentTime();
    }
  }

  func isOverride(current: Message?, next: Message?) -> Bool {
    return true
  }

  override func onReceive(message: Any) throws {
    switch message {
    case let m as Message:
      onMessage(message: m)
    case is Flush:
      onFlush()
    default:
      try super.onReceive(message: message)
    }
  }

  struct Message {
    let object: Any
    let actorRef: ActorRef
  }
  struct Flush {

  }
}
