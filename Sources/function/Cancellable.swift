//
//  Cancellable.swift
//  Aojet
//
//  Created by Qihe Bian on 7/15/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Cancellable {
  var isCancelled: Bool { get }
  func cancel()
}

class CancellableSimple: Cancellable {
  private var _isCancelled: Bool = false
  var isCancelled: Bool {
    get {
      return _isCancelled
    }
  }

  func cancel() {
    _isCancelled = true
  }
}
