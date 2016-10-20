
import Aojet

RuntimeEnvironment.isProduction = false
do {
  class SomeActor: Actor {
    override func onReceive(message: Any) throws {
      switch message {
      case let m as DoSomething:
        doSomething(object: m.object)
      default:
        try super.onReceive(message: message)
      }
    }

    func doSomething(object: Any) { //This should run on the actor thread.
      print(Thread.current)
      print("Do something with object: \(object)")
      //Do something
    }

    struct DoSomething {
      let object: Any
    }

  }

  let actorSystem = ActorSystem()
  actorSystem.traceInterface = ActorTrace() //For internal logging
  let actor = try actorSystem.actorOf(path: "some_actor_1", creator: AnyActorCreator{ () -> Actor in
    return SomeActor()
  })

  actor.send(message: SomeActor.DoSomething(object: "An object"))
  actor.send(message: "An string")
  actor.send(message: SomeActor.DoSomething(object: "Another object"))
}

do {
class SomeActor: AskableActor {

  override func onAsk(message: Any) throws -> Promise<Any>? {
    switch message {
    case let m as AskSomething:
      return askSomething(object: m.object)
    default:
      let p = try super.onAsk(message: message)
      print("Promise: \(p)")
      return p
    }
  }

  override func onReceive(message: Any) throws {
    switch message {
    case let m as DoSomething:
      doSomething(object: m.object)
    default:
      try super.onReceive(message: message)
    }
  }

  func doSomething(object: Any) { //This should run on the actor thread.
    print(Thread.current)
    print("Do something with object: \(object)")
    //Do something
  }

  func askSomething(object: Any) -> Promise<Any> { //This should run on the actor thread.
    print(Thread.current)
    print("Ask something with object: \(object)")

    return Promise(value: "A response")
  }

  struct DoSomething {
    let object: Any
  }
  
  struct AskSomething {
    let object: Any
  }
}

  let actorSystem = ActorSystem()
  actorSystem.traceInterface = ActorTrace() //For internal logging
  let actor = try actorSystem.actorOf(path: "some_actor_2", creator: AnyActorCreator{ () -> Actor in
    return SomeActor()
  })


  let p1: Promise<String> = actor.ask(message: SomeActor.AskSomething(object: "An object for ask")) //Success
  p1.then { (res) in
    print("Ask response:\(res)")
  }.failure { (error) in
    print("Ask error:\(error)")
  }

  actor.send(message: SomeActor.DoSomething(object: "An object")) //Success
  actor.send(message: "An string") //Drop

  let p2: Promise<String> = actor.ask(message: SomeActor.DoSomething(object: "An object for doing something")) //Error, not handle
  p2.then { (res) in
    print("Ask response:\(res)")
    }.failure { (error) in
      print("Ask error:\(error)")
  }
}


enum TestError: Error {
  case general(message: String)
}

//Immediate Promise
Promise(value: 1).then { (res) in
  print(res)
}.failure { (error) in
  print(error)
}

Promise<Int>(error: TestError.general(message: "Test error occur.")).then { (res) in
  print(res)
}.failure { (error) in
  print(error)
}

Promise<String> { (resolver) in
  let url = URL(string: "https://api.ipify.org") //Get client's IP address

  let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
    if error != nil {
      resolver.error(error!)
    } else if data != nil {
      let s = String(bytes: data!, encoding: String.Encoding.utf8)
      print(s)
      resolver.result(s)
    } else {
      resolver.result(nil)
    }
  }
  task.resume()
  }.then { (res) in
    print(res)
}

RunLoop.current.run()
