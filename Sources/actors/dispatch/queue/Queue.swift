//
//  Queue.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class Queue<T>: Equatable {
  final let id: Int
  final var queue = Array<T>()
  var isLocked = false

  init(id: Int) {
    self.id = id
  }

}

func ==<T>(lhs: Queue<T>, rhs: Queue<T>) -> Bool {
  return lhs.id == rhs.id
}
