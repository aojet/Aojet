//
//  DispatcherProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class DispatcherProvider: Dispatcher {
  let objectId: Identifier
  
  init() {
    objectId = type(of: self).generateObjectId()
  }

  func dispatch(runnable: Runnable, delay: TimeInterval) -> DispatchCancel {
    let q = DispatchQueue(label: "aojet.actor.background", attributes: [])
    q.asyncAfter(deadline: DispatchTime.now() + delay) {
      runnable.run()
    }
    return DispatchCancelImpl()
  }

}

private class DispatchCancelImpl: DispatchCancel {

  func cancel() {
    // Do Nothing
  }
}
