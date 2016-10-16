//
//  PoisonPill.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public final class PoisonPill: CustomStringConvertible {
  public static let instance = PoisonPill()

  private init() {

  }

  public var description: String {
    get {
      return "PoisonPill"
    }
  }
}
