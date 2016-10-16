//
//  QueueCollection.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class QueueCollection<T> {

  private let nextId = Runtime.createAtomicLong(initial: 0)
  private var queues = Dictionary<Int, Queue<T>>()
  private var pending = Array<Queue<T>>()
  private var listeners = Array<QueueCollectionListener>()
  private let lock = Runtime.createLock()

  func addListener(listener: QueueCollectionListener) {
    lock.lock()
    defer { lock.unlock() }
    if !listeners.contains(where: { (obj) -> Bool in
      return obj.objectId == listener.objectId
    }) {
      listeners.append(listener)
    }
  }

  func removeListener(listener: QueueCollectionListener) {
    lock.lock()
    defer { lock.unlock() }
    let index = listeners.index { (obj) -> Bool in
      return obj.objectId == listener.objectId
    }
    if index != nil {
      listeners.remove(at: index!)
    }
  }

  func spawnQueue() -> Int {
    lock.lock()
    defer { lock.unlock() }
    let id = Int(nextId.getAndIncrement())
    queues[id] = Queue<T>(id: id)
    return id
  }

  func disposeQueue(id: Int) {
    lock.lock()
    defer { lock.unlock() }
    let q = queues.removeValue(forKey: id)
    if q != nil {
      let index = pending.index { (obj) -> Bool in
        return q == obj
      }
      if index != nil {
        pending.remove(at: index!)
      }
    }
  }

  func post(id: Int, value: T) {
    post(id: id, value: value, isFirst: false)
  }

  func post(id: Int, value: T, isFirst: Bool) {
    lock.lock()
    defer { lock.unlock() }
    guard let queue = queues[id] else {
      return
    }

    let wasEmptyPending = pending.isEmpty
    let wasEmpty = queue.queue.isEmpty

    if isFirst {
      queue.queue.insert(value, at: 0)
    } else {
      queue.queue.append(value)
    }

    if wasEmpty && !queue.isLocked {
      pending.append(queue)
    }

    if wasEmptyPending {
      for l in listeners {
        l.onChanged()
      }
    }
  }
  
  func fetch() -> QueueFetchResult<T>? {
    lock.lock()
    defer { lock.unlock() }
    if pending.isEmpty {
      return nil
    }

    let queue = pending.removeFirst()
    queue.isLocked = true
    let val = queue.queue.removeFirst()
    return QueueFetchResult(id: queue.id, val: val)
  }

  func returnQueue(res: QueueFetchResult<T>) {
    lock.lock()
    defer { lock.unlock() }
    guard let queue = queues[res.id] else {
      return
    }
    queue.isLocked = false

    if !queue.queue.isEmpty {
      let wasEmptyPending = pending.isEmpty
      pending.append(queue)
      if wasEmptyPending {
        for l in listeners {
          l.onChanged()
        }
      }
    }
  }

  func allPending(id: Int) -> Array<T> {
    lock.lock()
    defer { lock.unlock() }
    guard let queue = queues[id] else {
      return Array()
    }

    let array = queue.queue
    return array
  }
}
