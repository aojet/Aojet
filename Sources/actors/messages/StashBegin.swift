//
//  StashBegin.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class StashBegin: CustomStringConvertible {
  static let instance = StashBegin()

  private init() {

  }

  var description: String {
    get {
      return "StashBegin"
    }
  }
}
