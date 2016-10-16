//
//  QueueFetchResult.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

struct QueueFetchResult<T> {

  let id: Int
  let val: T

  init(id: Int, val: T) {
    self.id = id
    self.val = val
  }

}
