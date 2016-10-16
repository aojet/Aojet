//
//  LogRuntimeProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class LogRuntimeProvider: LogRuntime {

  func warning(tag: String, message: String) {
    print("WARNING \(tag): \(message)")
  }

  func error(tag: String, error: Error) {
    print("ERROR \(tag): \(error)")
  }

  func debug(tag: String, message: String) {
    print("DEBUG \(tag): \(message)")
  }

  func verbose(tag: String, message: String) {
    print("VERBOSE \(tag): \(message)")
  }

}
