//
//  PromisesArray.swift
//  Aojet
//
//  Created by Qihe Bian on 9/21/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public class PromisesArray<R> {
  public class func of<R1>(array: Array<R1>) -> PromisesArray<R1> {
    var res = Array<Promise<R1>>()
    for r in array {
      res.append(Promise.success(value: r))
    }
    return PromisesArray<R1>(executor: AnyPromiseFunc { (executor) in
      executor.result(res)
    })
  }

  public class func of<R1>(items: R1...) -> PromisesArray<R1> {
    var res = Array<Promise<R1>>()
    for r in items {
      res.append(Promise.success(value: r))
    }
    return PromisesArray<R1>(executor: AnyPromiseFunc { (executor) in
      executor.result(res)
    })
  }

  public class func ofPromises<R1>(items: Array<Promise<R1>>) -> PromisesArray<R1> {
    let res = items
    return PromisesArray<R1>(executor: AnyPromiseFunc { (executor) in
      executor.result(res)
    })
  }

  public class func ofPromises<R1>(items: Promise<R1>...) -> PromisesArray<R1> {
    let res = items
    return PromisesArray<R1>(executor: AnyPromiseFunc { (executor) in
      executor.result(res)
    })
  }

  private var promises: Promise<Array<Promise<R>>>

  private init(promises: Promise<Array<Promise<R>>>) {
    self.promises = promises
  }

  private convenience init(executor: AnyPromiseFunc<Array<Promise<R>>>) {
    self.init(promises: Promise<Array<Promise<R>>>(executor: executor))
  }

  func map<R1>(_ func: AnyFunction<R?, Promise<R1>>) -> PromisesArray<R1> {
    return mapSourcePromises(AnyFunction<Promise<R>, Promise<R1>> { (srcPromise) -> Promise<R1> in
      return Promise<R1>(executor: AnyPromiseFunc<R1> { (resolver) in
        srcPromise.then(AnyConsumer { (t) in
          let mapped = `func`.apply(t)
          mapped.then(AnyConsumer { (t2) in
            resolver.result(t2)
          })
          mapped.failure(AnyConsumer { (e) in
            resolver.error(e)
          })
        })
        srcPromise.failure(AnyConsumer { (e) in
          resolver.error(e)
        })
      })
    })
  }

  public func map<R1>(_ closure: @escaping (R?) -> Promise<R1>) -> PromisesArray<R1> {
    return map(AnyFunction(closure))
  }

  func mapOptional<R1>(_ func: AnyFunction<R?, Promise<R1>>) -> PromisesArray<R1> {
    return map(`func`).ignoreFailed().filterNull()
  }

  public func mapOptional<R1>(_ closure: @escaping (R?) -> Promise<R1>) -> PromisesArray<R1> {
    return mapOptional(AnyFunction(closure))
  }

  public func ignoreFailed() -> PromisesArray<R> {
    return mapSourcePromises(AnyFunction { (tPromise) -> Promise<R> in
      return Promise<R>(executor: AnyPromiseFunc { (resolver) in
        tPromise.then(AnyConsumer { (t) in
          resolver.result(t)
        })
        tPromise.failure(AnyConsumer { (e) in
          resolver.result(nil)
        })
      })
    })
  }

  public func filterNull() -> PromisesArray<R> {
    return filter(predicate: AnyPredicate { (o) -> Bool in
      return o != nil
    })
  }

  private func mapSourcePromises<R1>(_ func: AnyFunction<Promise<R>, Promise<R1>>) -> PromisesArray<R1> {
    return PromisesArray<R1>(executor: AnyPromiseFunc { (executor) in
      self.promises.then(AnyConsumer { (sourcePromises) in
        var mappedPromises = Array<Promise<R1>>()
        if sourcePromises != nil {
          for p in sourcePromises! {
            mappedPromises.append(`func`.apply(p))
          }
        }
        executor.result(mappedPromises)
      })
      self.promises.failure(AnyConsumer { (e) in
        executor.error(e)
      })
    })
  }

  func filter(predicate: AnyPredicate<R?>) -> PromisesArray<R> {
    return flatMap(AnyFunction { (t) -> Array<R?> in
      if predicate.apply(t) {
        return Array(arrayLiteral: t)
      }
      return Array()
    })
  }

  public func filter(predicate: @escaping (R?) -> Bool) -> PromisesArray<R> {
    return filter(predicate: AnyPredicate(predicate))
  }

  func sort(comparator: AnyComparator<R?>) -> PromisesArray<R> {
    return flatMapAll(AnyFunction { (ts) -> Array<R?> in
      return ts.sorted(by: { (o1, o2) -> Bool in
        return comparator.compare(o1, o2) < 0
      })
    })
  }

  public func sort(compare: @escaping (R?, R?) -> Bool) -> PromisesArray<R> {
    return sort(comparator: AnyComparator { (o1, o2) -> Int in
      if compare(o1, o2) {
        return -1
      } else {
        return 1
      }
    })
  }

  public func first(count: Int) -> PromisesArray<R> {
    return flatMapAll(AnyFunction { (ts) -> Array<R?> in
      let len = min(count, ts.count)
      return Array(ts.dropFirst(len))
    })
  }

  public func first() -> Promise<R> {
    return first(count: 1).zip().map(AnyFunction { (src) -> R? in
      if src == nil || src!.count == 0 {
        try! type(of: self).exception(message: "Array is empty (first)")
      }
      return src![0]
    })
  }

  public func random() -> Promise<R> {
    return flatMapAll(AnyFunction { (ts) -> Array<R?> in
      if ts.count == 0 {
        try! type(of: self).exception(message: "Array is empty")
      }
      let i = Int(arc4random_uniform(UInt32(ts.count)))
      return Array(arrayLiteral: ts[i])
    }).first()
  }

  func flatMapAll<R1>(_ func: AnyFunction<Array<R?>, Array<R1?>>) -> PromisesArray<R1> {
    return PromisesArray<R1>(promises: Promise(executor: AnyPromiseFunc { (resolver) in
      self.promises.then(AnyConsumer { (sourcePromises) in
        if sourcePromises != nil && sourcePromises!.count > 0 {
          var res = Array<R?>(repeating: nil, count: sourcePromises!.count)
          var ended = Array<Bool?>(repeating: nil, count: sourcePromises!.count)
          for i in 0..<sourcePromises!.count {
            let index = i
            sourcePromises![i].then(AnyConsumer { (t) in
              res[index] = t
              ended[index] = true

              for i1 in 0..<sourcePromises!.count {
                if ended[i1] == nil || !ended[i1]! {
                  return
                }
              }
              let resMap = `func`.apply(res)
              var resultArray = Array<Promise<R1>>()
              for r in resMap {
                resultArray.append(Promise<R1>.success(value: r))
              }
              resolver.result(resultArray)
            })
            sourcePromises![i].failure(AnyConsumer { (e) in
              resolver.error(e)
            })
          }
        } else {
          resolver.result(Array())
        }
      })
      self.promises.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    }))
  }

  public func flatMapAll<R1>(_ closure: @escaping (Array<R?>) -> Array<R1?>) -> PromisesArray<R1> {
    return flatMapAll(AnyFunction(closure))
  }

  func flatMap<R1>(_ func: AnyFunction<R?, Array<R1?>>) -> PromisesArray<R1> {
    return PromisesArray<R1>(promises: Promise(executor: AnyPromiseFunc { (resolver) in
      self.promises.then(AnyConsumer { (sourcePromises) in
        if sourcePromises != nil && sourcePromises!.count > 0 {
          var res = Array<Array<R1?>?>(repeating: nil, count: sourcePromises!.count)
          var ended = Array<Bool?>(repeating: nil, count: sourcePromises!.count)
          for i in 0..<sourcePromises!.count {
            let index = i
            sourcePromises![i].then(AnyConsumer { (t) in
              res[index] = `func`.apply(t)
              ended[index] = true

              for i1 in 0..<sourcePromises!.count {
                if ended[i1] == nil || !ended[i1]! {
                  return
                }
              }
              var resultArray = Array<Promise<R1>>()
              for i2 in 0..<sourcePromises!.count {
                let a = res[i2]
                if a != nil {
                  for j in 0..<a!.count {
                    resultArray.append(Promise.success(value: a![j]))
                  }
                }
              }
              resolver.result(resultArray)
            })
            sourcePromises![i].failure(AnyConsumer { (e) in
              resolver.error(e)
            })
          }
        } else {
          resolver.result(Array())
        }
      })
      self.promises.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    }))
  }

  public func flatMap<R1>(_ closure: @escaping (R?) -> Array<R1?>) -> PromisesArray<R1> {
    return flatMap(AnyFunction(closure))
  }

  func zipPromise<R1>(_ func: AnyFunction<Array<R?>, Promise<R1>>) -> Promise<R1> {
    return Promise<R1>(executor: AnyPromiseFunc { (resolver) in
      self.promises.then(AnyConsumer { (promises1) in
        var res = Array<R?>()
        if promises1 != nil && promises1!.count > 0 {
          for _ in 0..<promises1!.count {
            res.append(nil)
          }
          var ended = Array<Bool?>(repeating: nil, count: promises1!.count)
          for i in 0..<promises1!.count {
            let index = i
            promises1![i].then(AnyConsumer { (t) in
              res[index] = t
              ended[index] = true
              for i1 in 0..<promises1!.count {
                if ended[i1] == nil || !ended[i1]! {
                  return
                }
              }
              `func`.apply(res).pipeTo(resolver: resolver)
            })
            promises1![i].failure(AnyConsumer { (e) in
              resolver.error(e)
            })
          }
        } else {
          `func`.apply(res).pipeTo(resolver: resolver)
        }
      })
      self.promises.failure(AnyConsumer { (e) in
        resolver.error(e)
      })
    })
  }

  public func zipPromise<R1>(_ closure: @escaping (Array<R?>) -> Promise<R1>) -> Promise<R1> {
    return zipPromise(AnyFunction(closure))
  }

  public func zip() -> Promise<Array<R?>> {
    return zipPromise(AnyFunction { (t) -> Promise<Array<R?>> in
      return Promise.success(value: t)
    })
  }

  private static func exception(message: String) throws {
    throw RuntimeException.general(message: message)
  }
}
