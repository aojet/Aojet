//
//  PromiseTools.swift
//  Aojet
//
//  Created by Qihe Bian on 9/21/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class PromiseTools {

  class func sort<T>(comparator: AnyComparator<T>) -> AnyFunction<Array<T>, Array<T>> {
    return AnyFunction { (ts) -> Array<T> in
      return ts.sorted(by: { (t1, t2) -> Bool in
        return comparator.compare(t1, t2) < 0
      })
    }
  }

  class func sort<T>(closure: @escaping (T, T) -> Bool) -> AnyFunction<Array<T>, Array<T>> {
    return sort(comparator: AnyComparator { (o1, o2) -> Int in
      if closure(o1, o2) {
        return -1
      } else {
        return 1
      }
    })
  }

  class func sort<T: Comparable>() -> AnyFunction<Array<T>, Array<T>> {
    return AnyFunction { (ts) -> Array<T> in
      return ts.sorted()
    }
  }
}
