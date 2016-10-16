//
//  Mailbox.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public class Mailbox {
  final let queueCollection: QueueCollection<Envelope>
  final let queueId: Int

  init(queueCollection: QueueCollection<Envelope>) {
    self.queueCollection = queueCollection
    self.queueId = queueCollection.spawnQueue()
  }

  func schedule(envelope: Envelope) throws {
    if envelope.mailbox !== self {
      throw RuntimeException.general(message: "envelope.mailbox != this mailbox")
    }
    queueCollection.post(id: queueId, value: envelope)
  }

  func scheduleFirst(envelope: Envelope) throws {
    if envelope.mailbox !== self {
      throw RuntimeException.general(message: "envelope.mailbox != this mailbox")
    }
    queueCollection.post(id: queueId, value: envelope, isFirst: true)
  }

  func dispose() -> Array<Envelope> {
    let res = queueCollection.allPending(id: queueId)
    queueCollection.disposeQueue(id: queueId)
    return res
  }
}
