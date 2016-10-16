//
//  ActorScope.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public class ActorScope {
  public let actorSystem: ActorSystem
  public let mailbox: Mailbox
  public let dispatcher: ActorDispatcher
  public let  path: String
  public let props: Props
  public let endpoint: ActorEndpoint
  private(set) var ref: ActorRef
  private(set) var actor: Actor! = nil

  public var message: Any?
  public var sender: ActorRef?

  init(actorSystem: ActorSystem,
       mailbox: Mailbox,
       dispatcher: ActorDispatcher,
       path: String,
       props: Props,
       endpoint: ActorEndpoint) {
    self.actorSystem = actorSystem
    self.mailbox = mailbox
    self.ref = ActorRef(endpoint: endpoint, system: actorSystem, path: path)
    self.dispatcher = dispatcher
    self.path = path
    self.props = props
    self.endpoint = endpoint
  }

  func onActorCreated(actor: Actor) {
    self.actor = actor
  }

  func onActorDie() {
    actor = nil
    sender = nil
    message = nil
  }
}
