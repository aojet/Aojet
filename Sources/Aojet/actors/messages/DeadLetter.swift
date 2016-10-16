//
//  DeadLetter.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class DeadLetter: CustomStringConvertible {
  let message: Any

  init(message: Any) {
    self.message = message
  }

  var description: String {
    get {
      return "DeadLetter(\(message))"
    }
  }
}
