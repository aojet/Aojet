//
//  PromiseResolver.swift
//  Aojet
//
//  Created by Qihe Bian on 9/21/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public final class PromiseResolver<R> {
  private(set) var promise: Promise<R>

  public init(promise: Promise<R>) {
    self.promise = promise
  }

  public func result(_ res: R?) {
    promise.result(res)
  }

  public func tryResult(_ res: R?) {
    promise.tryResult(res)
  }

  public func error(_ e: Error) {
    promise.error(e)
  }

  public func tryError(_ e: Error) {
    promise.tryError(e)
  }

}
