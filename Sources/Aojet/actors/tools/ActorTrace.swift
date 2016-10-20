//
//  ActorTrace.swift
//  Aojet
//
//  Created by Qihe Bian on 10/20/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

open class ActorTrace: TraceInterface {

  private static let tag = "ACTOR_SYSTEM"
  private static let processThreshold: TimeInterval = 100

  public init() {

  }

  open func onEnvelopeDelivered(envelope: Envelope) {
    Log.debug(tag: type(of: self).tag, message: "\(envelope.scope.path) {\(envelope.message)} delivered")
  }

  open func onEnvelopeProcessed(envelope: Envelope, duration: TimeInterval) {
    if duration > type(of: self).processThreshold {
      Log.warning(tag: type(of: self).tag, message: "Too long \(envelope.scope.path) {\(envelope.message)} in \(duration) ms")
    }
  }

  open func onDrop(sender: ActorRef?, message: Any, actor: Actor) {
    Log.warning(tag: type(of: self).tag, message: "Drop: \(message)")
  }

  open func onDeadLetter(receiver: ActorRef, message: Any) {
    Log.warning(tag: type(of: self).tag, message: "Dead Letter: \(message)")
  }

  open func onActorDie(ref: ActorRef, envelope: Envelope, error: Error) {
    Log.warning(tag: type(of: self).tag, message: "Die(\(ref.path)) by \(envelope.message) with \(error)")
    Log.error(tag: type(of: self).tag, error: error)
  }

  open func onMessageSent(ref: ActorRef, message: Any) {
    Log.debug(tag: type(of: self).tag, message: "Sent: \(message)")
  }

}
