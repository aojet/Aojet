//
//  Identifiable.swift
//  Aojet
//
//  Created by Qihe Bian on 8/29/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public typealias Identifier = NSUUID

public protocol Identifiable {
  var objectId: Identifier { get }
}

public protocol IdentifierHashable: Identifiable, Hashable {

}

public extension Identifiable {
  static func generateObjectId() -> Identifier {
    return Identifier()
  }
}

public extension IdentifierHashable {
  var hashValue: Int {
    get {
      return objectId.hashValue
    }
  }
}

public func ==<T>(lhs: T, rhs: T) -> Bool where T:IdentifierHashable {
  return lhs.objectId == rhs.objectId
}
