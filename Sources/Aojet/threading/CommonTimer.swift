//
//  CommonTimer.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class CommonTimer {
  static let commonTimerActor: ActorRef = try! ActorSystem.system.actorOf(path: "common_timer", creator: AnyActorCreator({
    return Actor()
  }))
  static let commonScheduler = Scheduler(ref: commonTimerActor)
  let runnable: Runnable
  var lastSchedule: ActorCancellable?
  var isDisposed: Bool = false

  init(runnable: Runnable) {
    self.runnable = runnable
  }

  func schedule(time: TimeInterval) {
    if (isDisposed) {
      return
    }

    if (lastSchedule != nil) {
      lastSchedule!.cancel()
    }

    lastSchedule = type(of: self).commonScheduler.schedule(runnable: runnable, delay: time)
  }

  func cancel() {
    if (lastSchedule != nil) {
      lastSchedule!.cancel()
    }
  }

  func dispose() {
    isDisposed = true
    cancel()
  }
}
