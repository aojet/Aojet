//
//  ActorTime.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class ActorTime {
  class func currentTime() -> TimeInterval {
    return Runtime.actorTime()
  }
}
