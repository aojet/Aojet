//
//  ImmediateDispatcherProvider.swift
//  Aojet
//
//  Created by Qihe Bian on 9/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

class ImmediateDispatcherProvider: ImmediateDispatcher {
  let threadPool: ThreadPool
  let lock = Runtime.createLock()

  init(name: String, priority: ThreadPriority) {
    let qos: qos_class_t = {
      switch priority {
      case .high:
        return QOS_CLASS_USER_INITIATED
      case .low:
        return QOS_CLASS_UTILITY
      case .normal:
        return QOS_CLASS_DEFAULT
      }
    }()
    threadPool = ThreadPool(name: name, threadCount: 1, qos: qos)
  }

  func dispatchNow(runnable: Runnable) {
    lock.lock()
    defer { lock.unlock() }
    threadPool.execute(runnable)
  }

}

class ThreadPool {
  let tasksQueue: Queue

  var threads: Array<pthread_t>
  let name: String?
  let threadCount: Int
  let qos: qos_class_t

  var isStop: Bool

  var mutex: pthread_mutex_t
  var cond: pthread_cond_t

  init(name: String?, threadCount: Int, qos: qos_class_t) {
    self.name = name
    self.threadCount = threadCount
    self.qos = qos
    isStop = false

    mutex = pthread_mutex_t()
    cond = pthread_cond_t()

    pthread_mutex_init(&mutex, nil)
    pthread_cond_init(&cond, nil)

    tasksQueue = Queue()

    threads = Array()
    let holder = Unmanaged.passRetained(self)
    for _ in 0..<threadCount {
      let pointer = UnsafeMutableRawPointer(holder.toOpaque())

      var thread: pthread_t? = nil
      var user_interactive_qos_attr = pthread_attr_t()
      pthread_attr_init(&user_interactive_qos_attr)
      pthread_attr_set_qos_class_np(&user_interactive_qos_attr, qos, 0)
      guard pthread_create(&thread, &user_interactive_qos_attr, threadRun, pointer) == 0 && thread != nil else {
        holder.release()
        break
      }
      threads.append(thread!)
    }
  }

  deinit {
    isStop = true
    stop()
  }

  func execute(_ runnable: Runnable) {
    let task: Task = Task(data: runnable) { (data) in
      let r = data as! Runnable
      r.run()
    }
    addTask(task)
  }

  func addTask(_ task: Task) {
    guard pthread_mutex_lock(&mutex) == 0 else {
      return
    }
    tasksQueue.enqueue(task)
    if tasksQueue.count == 1 {
      guard pthread_cond_broadcast(&cond) == 0 else {
        guard pthread_mutex_unlock(&mutex) == 0 else {
          return
        }
        return
      }
    }
    guard pthread_mutex_unlock(&mutex) == 0 else {
      return
    }
    return
  }

  func peekTask() -> Task? {
    guard pthread_mutex_lock(&mutex) == 0 else {
      return nil
    }
    while tasksQueue.isEmpty {
      if isStop {
        pthread_cond_broadcast(&cond)
        pthread_mutex_unlock(&mutex)
        return nil
      }
      guard pthread_cond_wait(&cond, &mutex) == 0 else {
        pthread_mutex_unlock(&mutex)
        return nil
      }
    }
    let task = tasksQueue.dequeue() as? Task
    if task == nil {

    }
    guard pthread_mutex_unlock(&mutex) == 0 else {
      return nil
    }
    return task
  }

  func threadRoutine() {
    if name != nil {
      pthread_setname_np(name!.cString(using: String.Encoding.utf8)!)
    }

    var running = true
    while running {
      autoreleasepool {
        guard let task = peekTask() else {
          if isStop {
            running = false
            return
          } else {
            running = false
            return
          }
        }
        task.closure(task.data)
      }
    }
  }

  func stop() {
    guard pthread_mutex_lock(&mutex) == 0 else {
      return
    }
    isStop = true
    while !tasksQueue.isEmpty {
      guard pthread_cond_wait(&cond, &mutex) == 0 else {
        pthread_mutex_unlock(&mutex)
        return
      }
    }
    pthread_cond_broadcast(&cond)
    guard pthread_mutex_unlock(&mutex) == 0 else {
      return
    }
    for thread in threads {
      if pthread_join(thread, nil) != 0 {

      }
    }
    threads.removeAll()
  }

  class Queue {

    var isEmpty: Bool {
      get {
        return count == 0
      }
    }
    var count: Int {
      get {
        return items.count
      }
    }

    private var items: Array<Any> = Array()
    init() {

    }

    func enqueue(_ data: Any) {
      items.append(data)
    }

    func dequeue() -> Any? {
      if items.count > 0 {
        return items.remove(at: 0)
      } else {
        return nil
      }
    }
  }

  class Task {
    let data: Any
    let closure: (Any) -> ()
    init(data: Any, closure: @escaping (Any) -> ()) {
      self.data = data
      self.closure = closure
    }
  }
}

private func threadRun(arg: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
  let unmanaged = Unmanaged<ThreadPool>.fromOpaque(arg)
  unmanaged.takeUnretainedValue().threadRoutine()
  unmanaged.release()
  return nil
}
