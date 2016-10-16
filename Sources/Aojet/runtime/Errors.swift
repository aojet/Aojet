//
//  Errors.swift
//  Aojet
//
//  Created by Qihe Bian on 9/22/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public enum RuntimeException: Error, CustomStringConvertible {
  case general(message: String)
  case actorHalter(message: String, nestedError: Error?)

  public var description: String {
    get {
      switch self {
      case .general(message: let msg):
        return "RuntimeException.general \(msg)"
      case .actorHalter(message: let msg, nestedError: let nestedError):
        var nestedErrorString = ""
        if nestedError != nil {
          nestedErrorString = "\n\(nestedError!)"
        }
        return "RuntimeException.actorHalter \(msg)\(nestedErrorString)"
//      default:
//        return String(describing: self)
      }
    }
  }
}
