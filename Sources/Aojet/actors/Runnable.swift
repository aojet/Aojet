//
//  Runnable.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public protocol Runnable: Identifiable {
  func run()
}

class AnyRunnable: Runnable, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _run: () -> ()

  init<T: Runnable>(_ base: T) {
    _base = base
    objectId = base.objectId
    _run = base.run
  }

  init(_ run: @escaping ()->()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _run = run
  }

  func run() {
    _run()
  }
}
