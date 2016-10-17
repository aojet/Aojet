//
//  ActorDispatcher.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import Foundation

public class ActorDispatcher {
  final let lock = Runtime.createLock()
  final var endpoints = Dictionary<String, ActorEndpoint>()
  final var scopes = Dictionary<String, ActorScope>()
  final let actorSystem: ActorSystem
  final let queueCollection = QueueCollection<Envelope>()
  public final let name: String
  final var dispatchers: Array<QueueDispatcher<Envelope>>

  init(name: String, priority: ThreadPriority, actorSystem: ActorSystem, dispatchersCount: Int) {
    self.name = name
    self.actorSystem = actorSystem
    self.dispatchers = Array()
    let handler = AnyConsumer<Envelope> { [weak self] envelope in
      guard let strongSelf = self else {
        return
      }
      strongSelf.processEnvelope(envelope: envelope)
    }
    for i in 0..<dispatchersCount {
      dispatchers.append(QueueDispatcher(name: "\(name)_\(i)", priority: priority, collection: queueCollection, handler: handler))
    }
  }

  final func referenceActor(path: String, props: Props) -> ActorRef {
    lock.lock()
    defer { lock.unlock() }
    if scopes.contains(where: { (key, obj) -> Bool in
      return path == key
    }) {
      return scopes[path]!.ref
    }
    let mailbox = Mailbox(queueCollection: queueCollection)
    var endpoint = endpoints[path]
    if endpoint == nil {
      endpoint = ActorEndpoint(path: path)
      endpoints[path] = endpoint
    }
    let scope = ActorScope(actorSystem: actorSystem, mailbox: mailbox, dispatcher: self, path: path, props: props, endpoint: endpoint!)
    endpoint!.connect(mailbox: mailbox, scope: scope)
    scopes[scope.path] = scope

    if !Runtime.isSingleThread() && !Runtime.isMainThread() {
      scope.ref.send(message: StartActor.instance)
    } else {
      Runtime.dispatch(runnable: AnyRunnable {
        scope.ref.send(message: StartActor.instance)
      })
    }
    return scope.ref
  }

  func processEnvelope(envelope: Envelope) {
    let scope = envelope.scope
    if actorSystem.traceInterface != nil {
      actorSystem.traceInterface!.onEnvelopeDelivered(envelope: envelope)
    }

    let start = ActorTime.currentTime()
    if scope.actor == nil {
      if envelope.message is PoisonPill {
        // Not creating actor for PoisonPill
        return
      }

      do {
        let actor = try scope.props.create()
        actor.initActor(path: scope.path, context: ActorContext(scope: scope), mailbox: scope.mailbox)
        ThreadDispatcher.pushDispatcher(actor.dispatcher)
        do {
          defer {
            ThreadDispatcher.popDispatcher()
          }
          do {
            try actor.preStart()
          }
        }
        scope.onActorCreated(actor: actor)

      } catch _ {
        print(Thread.callStackSymbols)
        if envelope.sender != nil {
          envelope.sender!.send(message: DeadLetter(message: "Unable to create actor"))
        }
        return
      }
    }

    do {
      defer {
        if actorSystem.traceInterface != nil {
          actorSystem.traceInterface!.onEnvelopeProcessed(envelope: envelope, duration: ActorTime.currentTime() - start)
        }
      }
      do {
        if envelope.message is StartActor {
          // Already created actor
        } else if (envelope.message is PoisonPill) {
          ThreadDispatcher.pushDispatcher(scope.actor!.dispatcher)
          do {
            defer {
              ThreadDispatcher.popDispatcher()
            }
            do {
              try scope.actor!.postStop()
            }
          }
          onActorDie(scope: scope)
        } else {
          scope.actor!.handle(message: envelope.message, sender: envelope.sender)
        }
      } catch let e {
        if actorSystem.traceInterface != nil {
          actorSystem.traceInterface!.onActorDie(ref: scope.ref, envelope: envelope, error: e)
        }
        ThreadDispatcher.pushDispatcher(scope.actor!.dispatcher)
        do {
          defer {
            ThreadDispatcher.popDispatcher()
          }
          do {
            try? scope.actor.postStop()
          }
        }
        onActorDie(scope: scope)
      }
    }
  }

  func onActorDie(scope: ActorScope) {
    scope.onActorDie()
    if scope.props.supervisor != nil {
      scope.props.supervisor!.onActorStopped(ref: scope.ref)
    }
    var deadLetters: Array<Envelope>
    lock.lock()
    scopes.removeValue(forKey: scope.path)
    endpoints.removeValue(forKey: scope.path)
    deadLetters = scope.mailbox.dispose()
    lock.unlock()

    for e in deadLetters {
      if e.sender != nil {
        e.sender!.send(message: DeadLetter(message: e.message))
      }
    }
  }
}
