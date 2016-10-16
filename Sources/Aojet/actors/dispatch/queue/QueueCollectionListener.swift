//
//  QueueCollectionListener.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol QueueCollectionListener: Identifiable {
  func onChanged()
}

class AnyQueueCollectionListener: QueueCollectionListener, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _onChanged: () -> ()

  init<T: QueueCollectionListener>(_ base: T) {
    _base = base
    objectId = base.objectId
    _onChanged = base.onChanged
  }

  init(_ closure: @escaping () -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _onChanged = closure
  }

  func onChanged() {
    _onChanged()
  }

}
