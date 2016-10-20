//
//  RuntimeEnvironment.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public class RuntimeEnvironment {
  private static var _isProduction: Bool? = nil
  public static var isProduction: Bool {
    get {
      if _isProduction == nil {
        print("RuntimeEnvironment.isProduction is not set, the default value is false.")
        _isProduction = false
      }
      return _isProduction!
    }
    set(isProduction) {
      _isProduction = isProduction
    }
  }

}
