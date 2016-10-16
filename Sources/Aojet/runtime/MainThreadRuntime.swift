//
//  MainThreadRuntime.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol MainThreadRuntime {
  func postToMainThread(runnable: Runnable)
  func isMainThread() -> Bool
  func isSingleThread() -> Bool

}
