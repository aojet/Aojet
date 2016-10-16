//
//  DispatcherRuntimeProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/22/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class DispatcherRuntimeProvider: DispatcherRuntime {
  func dispatch(runnable: Runnable) {
    DispatchQueue.global(qos: .background).async {
      runnable.run()
    }
  }
}
