//
//  RuntimeEnvironment.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class RuntimeEnvironment {
  private static var _isProduction: Bool? = nil
  static var isProduction: Bool {
    get {
      if _isProduction == nil {
        fatalError("isProduction not set.")
      }
      return _isProduction!
    }
    set(isProduction) {
      _isProduction = isProduction
    }
  }

}
