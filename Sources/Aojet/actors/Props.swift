//
//  Props.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public final class Props {
  final let creator: ActorCreator
  public final let dispatcher: String?
  public final let supervisor: ActorSupervisor?

  public init(dispatcher: String?, creator: ActorCreator, supervisor: ActorSupervisor?) {
    self.creator = creator
    self.dispatcher = dispatcher
    self.supervisor = supervisor
  }

  func create() throws -> Actor {
    return try creator.create()
  }

  public func changeDispatcher(dispatcher: String) -> Props {
    return Props(dispatcher: dispatcher, creator: creator, supervisor: supervisor)
  }

  public func changeSupervisor(supervisor: ActorSupervisor) -> Props {
    return Props(dispatcher: dispatcher, creator: creator, supervisor: supervisor)
  }

  public class func create(creator: ActorCreator) -> Props {
    return Props(dispatcher: nil, creator: creator, supervisor: nil)
  }
}
