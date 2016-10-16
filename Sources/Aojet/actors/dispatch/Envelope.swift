//
//  Envelope.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

/// Actor system envelope
class Envelope: CustomStringConvertible {

  /// Message in envelope
  final let message: Any

  /// Sender of message
  final let sender: ActorRef?


  /// Mailbox for envelope
  final let mailbox: Mailbox

  final let scope: ActorScope
  final let sendTime: TimeInterval


  /// Creating of envelope
  ///
  /// - parameter message: message
  /// - parameter scope:   scope
  /// - parameter mailbox: mailbox
  /// - parameter sender:  sender reference
  init(message: Any, scope: ActorScope, mailbox: Mailbox, sender: ActorRef?) {
    self.scope = scope
    self.message = message
    self.sender = sender
    self.mailbox = mailbox
    self.sendTime = ActorTime.currentTime()
  }

  var description: String {
    get {
      return "{\(message) -> \(scope.path)}"
    }
  }

}
