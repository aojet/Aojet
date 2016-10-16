//
//  ActorRef.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//


/// Reference to Actor that allows to send messages to real Actor
public final class ActorRef {
  public let endpoint: ActorEndpoint
  public let system: ActorSystem
  public let path: String

  init(endpoint: ActorEndpoint, system: ActorSystem, path: String) {
    self.endpoint = endpoint
    self.system = system
    self.path = path
  }


  /// Send message with empty sender
  ///
  /// - parameter message: message
  public func send(message: Any) {
    send(message: message, sender: nil)
  }


  /// Send message with specified sender
  ///
  /// - parameter message: message
  /// - parameter sender:  sender
  public func send(message: Any, sender: ActorRef?) {
    try? endpoint.mailbox.schedule(envelope: Envelope(message: message, scope: endpoint.scope, mailbox: endpoint.mailbox, sender: sender))
  }


  /// Sending message before all other messages
  ///
  /// - parameter message: message
  /// - parameter sender:  sender
  public func sendFirst(message: Any, sender: ActorRef?) {
    try? endpoint.mailbox.scheduleFirst(envelope: Envelope(message: message, scope: endpoint.scope, mailbox: endpoint.mailbox, sender: sender))
  }


  /// Execute on Actor Thread
  ///
  /// - parameter runnable: runnable
  public func post(runnable: Runnable) {
    send(message: runnable)
  }
}
