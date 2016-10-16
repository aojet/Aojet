//
//  QueueDispatcher.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

class QueueDispatcher<T>: QueueCollectionListener, IdentifierHashable {
  let objectId: Identifier

  /// Static stored properties not supported in generic types
  static var maxItems: Int {
    get {
      return 10
    }
  }
  private let lock = Runtime.createLock()
  private let collection: QueueCollection<T>
  private let handler: AnyConsumer<T>
  private let dispatcher: ImmediateDispatcher
  private var isInvalidated: Bool
  private var isProcessing: Bool
  private var checker: Runnable?

  init(name: String, priority: ThreadPriority, collection: QueueCollection<T>, handler: AnyConsumer<T>) {
    objectId = type(of: self).generateObjectId()
    isInvalidated = false
    isProcessing = false

    self.collection = collection
    self.handler = handler
    self.dispatcher = Runtime.createImmediateDispatcher(name: name, priority: priority)
    self.checker = AnyRunnable { [weak self] in
      guard let strongSelf = self else {
        return
      }
      strongSelf.lock.lock()
      strongSelf.isProcessing = true
      strongSelf.isInvalidated = false
      strongSelf.lock.unlock()
      var isFetched = false
      var iterations = 0
      while iterations < type(of: strongSelf).maxItems {
        let res = strongSelf.collection.fetch()
        if res != nil {
          isFetched = true
          do {
            defer {
              collection.returnQueue(res: res!)
            }
            do {
              try strongSelf.handler.apply(res!.val)
            } catch _ {
              
            }
          }
        } else {
          isFetched = false
          break
        }
        iterations += 1
      }
      strongSelf.lock.lock()
      if isFetched || strongSelf.isInvalidated {
        strongSelf.dispatcher.dispatchNow(runnable: strongSelf.checker!)
        strongSelf.isInvalidated = true
      } else {
        strongSelf.isInvalidated = false
      }
      strongSelf.isProcessing = false
      strongSelf.lock.unlock()
    }
    collection.addListener(listener: self)
    onChanged()
  }

  func onChanged() {
    lock.lock()
    defer { lock.unlock() }
    if isInvalidated {
      return
    }
    isInvalidated = true
    if !isProcessing {
      dispatcher.dispatchNow(runnable: checker!)
    }
  }
}
