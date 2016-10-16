//
//  Log.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

final class Log {
  private static let logRuntime: LogRuntime = LogRuntimeProvider()

  static func warning(tag: String, message: String) {
    if !RuntimeEnvironment.isProduction {
      logRuntime.warning(tag: tag, message: message)
    }
  }

  static func error(tag: String, error: Error) {
    logRuntime.error(tag: tag, error: error)
  }

  static func debug(tag: String, message: String) {
    if !RuntimeEnvironment.isProduction {
      logRuntime.debug(tag: tag, message: message)
    }
  }

  static func verbose(tag: String, message: String) {
    if !RuntimeEnvironment.isProduction {
      logRuntime.verbose(tag: tag, message: message)
    }
  }

}
