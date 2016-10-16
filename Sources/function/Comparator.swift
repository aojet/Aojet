//
//  Comparator.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/6.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol Comparator: Identifiable {
  associatedtype T
  func compare(_ o1: T, _ o2: T) -> Int
}

class AnyComparator<T>: Comparator, IdentifierHashable {
  private let _base: Any?
  let objectId: Identifier
  private let _compare: (_ o1: T, _ o2: T) -> Int

  init<S: Comparator>(base: S) where S.T == T {
    _base = base
    objectId = base.objectId
    _compare = base.compare
  }

  init(_ compare: @escaping (_ o1: T, _ o2: T) -> Int) {
    _base = nil
    objectId = type(of: self).generateObjectId()
    _compare = compare
  }

  func compare(_ o1: T, _ o2: T) -> Int {
    return _compare(o1, o2)
  }
}
