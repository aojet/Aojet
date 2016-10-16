//
//  Promises.swift
//  Aojet
//
//  Created by Qihe Bian on 9/21/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public class Promises {

  class func log<R>(tag: String, resolver: PromiseResolver<R>, func: AnyPromiseFunc<R>) -> Promise<R> {
    return Promise<R>(executor: AnyPromiseFunc { (r) in
      `func`.exec(resolver: r)
    }).then(AnyConsumer { (t) in
      Log.debug(tag: tag, message: "Result: \(t)")
      resolver.result(t)
    }).failure(AnyConsumer { (e) in
      Log.debug(tag: tag, message: "Error: \(e)")
      Log.error(tag: tag, error: e)
      print(Thread.callStackSymbols)
      resolver.error(e)
    })
  }

  public class func tuple<R1, R2>(p1: Promise<R1>, p2: Promise<R2>) -> Promise<(R1, R2)> {
    let t1 = p1.map { (t) -> Any? in
      return t
    }
    let t2 = p2.map { (t) -> Any? in
      return t
    }
    let p: Promise<Array<Any?>> = PromisesArray<Any?>.ofPromises(items: t1, t2).zip()
    return p.map(AnyFunction { (src) -> (R1, R2)? in
      let r1 = src![0] as! R1
      let r2 = src![1] as! R2
      return (r1, r2)
    })
  }

  public class func tuple<R1, R2, R3>(p1: Promise<R1>, p2: Promise<R2>, p3: Promise<R3>) -> Promise<(R1, R2, R3)> {
    let t1 = p1.map { (t) -> Any? in
      return t
    }
    let t2 = p2.map { (t) -> Any? in
      return t
    }
    let t3 = p3.map { (t) -> Any? in
      return t
    }
    let p: Promise<Array<Any?>> = PromisesArray<Any?>.ofPromises(items: t1, t2, t3).zip()
    return p.map(AnyFunction { (src) -> (R1, R2, R3)? in
      let r1 = src![0] as! R1
      let r2 = src![1] as! R2
      let r3 = src![2] as! R3
      return (r1, r2, r3)
    })
  }

  public class func tuple<R1, R2, R3, R4>(p1: Promise<R1>, p2: Promise<R2>, p3: Promise<R3>, p4: Promise<R4>) -> Promise<(R1, R2, R3, R4)> {
    let t1 = p1.map { (t) -> Any? in
      return t
    }
    let t2 = p2.map { (t) -> Any? in
      return t
    }
    let t3 = p3.map { (t) -> Any? in
      return t
    }
    let t4 = p4.map { (t) -> Any? in
      return t
    }
    let p: Promise<Array<Any?>> = PromisesArray<Any?>.ofPromises(items: t1, t2, t3, t4).zip()
    return p.map(AnyFunction { (src) -> (R1, R2, R3, R4)? in
      let r1 = src![0] as! R1
      let r2 = src![1] as! R2
      let r3 = src![2] as! R3
      let r4 = src![3] as! R4
      return (r1, r2, r3, r4)
    })
  }

  class func _traverse<R>(queue: inout Array<AnySupplier<Promise<R>>>) -> Promise<R> {
    var queue = queue
    if queue.count == 0 {
      return Promise.success(value: nil)
    }
    return queue.remove(at: 0).get().flatMap(AnyFunction { (v) -> Promise<R> in
      _traverse(queue: &queue)
    })
  }

  class func traverse<R>(queue: Array<AnySupplier<Promise<R>>>) -> Promise<R> {
    var queue = queue
    return _traverse(queue: &queue)
  }

  public class func traverse<R>(queue: Array<()->Promise<R>>) -> Promise<R> {
    let q = queue.map { (closure) -> AnySupplier<Promise<R>> in
      return AnySupplier(closure)
    }
    return traverse(queue: q)
  }
}
