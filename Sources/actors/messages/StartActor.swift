//
//  StartActor.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

final class StartActor: CustomStringConvertible {
  static let instance = StartActor()

  private init() {

  }

  var description: String {
    get {
      return "StartActor"
    }
  }

}
