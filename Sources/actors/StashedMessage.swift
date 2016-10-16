//
//  StashedMessage.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

struct StashedMessage {
  let message: Any
  let sender: ActorRef?

  init(message: Any, sender: ActorRef?) {
    self.message = message
    self.sender = sender
  }
}
