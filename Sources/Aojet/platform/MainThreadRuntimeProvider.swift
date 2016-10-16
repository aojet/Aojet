//
//  MainThreadRuntimeProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/22/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class MainThreadRuntimeProvider: MainThreadRuntime {
  func postToMainThread(runnable: Runnable) {
    DispatchQueue.main.async {
      runnable.run()
    }
  }

  func isMainThread() -> Bool {
    return Thread.current.isMainThread
  }

  func isSingleThread() -> Bool {
    return false
  }

}
