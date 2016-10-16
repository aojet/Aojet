//
//  Dispatcher.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Dispatcher: Identifiable {

  func dispatch(runnable: Runnable, delay: TimeInterval) -> DispatchCancel
  
}

class AnyDispatcher: Dispatcher, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _dispatch: (_ runnable: Runnable, _ delay: TimeInterval) -> DispatchCancel

  init<T: Dispatcher>(_ base: T) {
    _base = base
    objectId = base.objectId
    _dispatch = base.dispatch
  }

  init(_ dispatch: @escaping (_ runnable: Runnable, _ delay: TimeInterval)->DispatchCancel) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _dispatch = dispatch
  }

  func dispatch(runnable: Runnable, delay: TimeInterval) -> DispatchCancel {
    return _dispatch(runnable, delay)
  }
}
