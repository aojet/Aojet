//
//  TraceInterface.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol TraceInterface {

  func onEnvelopeDelivered(envelope: Envelope)
  func onEnvelopeProcessed(envelope: Envelope, duration: TimeInterval)
  func onDrop(sender: ActorRef?, message: Any, actor: Actor)
  func onDeadLetter(receiver: ActorRef, message: Any)
  func onActorDie(ref: ActorRef, envelope: Envelope, error: Error)
  func onMessageSent(ref: ActorRef, message: Any)
  
}
