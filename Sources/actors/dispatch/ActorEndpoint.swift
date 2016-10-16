//
//  ActorEndpoint.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public final class ActorEndpoint {

  public final let path: String

  public private(set) var mailbox: Mailbox!

  public private(set) var scope: ActorScope!

  public init(path: String) {
    self.path = path
  }

  public func connect(mailbox: Mailbox, scope: ActorScope) {
    self.mailbox = mailbox
    self.scope = scope
  }
}
