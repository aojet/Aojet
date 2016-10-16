//
//  ActorCancellable.swift
//  Aojet
//
//  Created by Qihe Bian on 7/12/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

protocol ActorCancellable: Identifiable {

  func cancel()
}

final class AnyActorCancellable: ActorCancellable, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _cancel: () -> ()

  init<T: ActorCancellable>(_ base: T) {
    _base = base
    objectId = base.objectId
    _cancel = base.cancel
  }

  init(_ closure: @escaping ()->()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _cancel = closure
  }

  func cancel() {
    _cancel()
  }
}
