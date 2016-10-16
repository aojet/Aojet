//
//  Receiver.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public protocol Receiver: Identifiable {
  func onReceive(message: Any) throws
}

public final class AnyReceiver: Receiver, IdentifierHashable {
  private let _base: Any?
  public let objectId: Identifier
  let _onReceive: (_ message: Any) throws -> ()

  init<T: Receiver>(_ base: T) {
    _base = base
    objectId = base.objectId
    _onReceive = base.onReceive
  }

  init(_ closure: @escaping (_ message: Any) throws -> ()) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _onReceive = closure
  }

  public func onReceive(message: Any) throws {
    try _onReceive(message)
  }

}
