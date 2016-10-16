//
//  LockProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class LockProvider: Lock {
  private var mutex = pthread_mutex_t()
  private var attr = pthread_mutexattr_t()

  init() {
    pthread_mutexattr_init(&attr)
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(&mutex, &attr)
  }

  deinit {
    pthread_mutexattr_destroy(&attr)
    pthread_mutex_destroy(&mutex)
  }

  func lock() {
    pthread_mutex_lock(&mutex)
  }

  func unlock() {
    pthread_mutex_unlock(&mutex)
  }
}
