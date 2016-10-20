# Aojet

[![GitHub license](https://img.shields.io/github/license/aojet/Aojet.svg)](https://raw.githubusercontent.com/aojet/Aojet/master/LICENSE)
[![GitHub release](https://img.shields.io/github/release/aojet/Aojet.svg)](https://github.com/aojet/Aojet/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/aojet/Aojet)

Aojet is an [actor model](https://en.wikipedia.org/wiki/Actor_model) implemetion for swift.

## Features

- [x] Asynchronous, non-blocking and highly performant message-driven programming model
- [x] Safe as well as efficient messaging
- [x] Message ordering using Local Synchronization Constraints
- [x] Fair scheduling
- [x] Modular and extensible
- [x] A [promise](https://en.wikipedia.org/wiki/Futures_and_promises) implementation for general usage
- [ ] Portable(Support iOS and Mac platform currently)

## Requirements

- Swift 3.0
- iOS 8.0+ or macOS 10.10+

-----

## Installation

Aojet is available through [Carthage](https://github.com/Carthage/Carthage).
Add this line to your `Cartfile`

```bash
github "aojet/Aojet"
```

-----

## Usage

### Make an Actor

This is a simple actor implementation:

```swift

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


```

### Create ActorRef

```swift

let actorSystem = ActorSystem.system
actorSystem.traceInterface = ActorTrace() //For internal logging
let actor = try actorSystem.actorOf(path: "testActor", creator: AnyActorCreator{ () -> Actor in
  return SomeActor()
})


```

### Send Message to ActorRef


```swift

actor.send(message: SomeActor.DoSomething(object: "An object")) //Success
actor.send(message: "An string") //Drop
actor.send(message: SomeActor.DoSomething(object: "Another object")) //Success


```

### Make an AskableActor


```swift

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


```

### Make an Ask Request

```swift

 let p1: Promise<String> = actor.ask(message: SomeActor.AskSomething(object: "An object for ask"))
 p1.then { (res) in
   print("Ask response:\(res)")
 }.failure { (error) in
   print("Ask error:\(error)")
 }
  
```

### Promise Usage

There are some ways to create a promise:

```swift
//Define an error for test
enum TestError: Error {
  case general(message: String)
}

//Immediate Promise
let p1 = Promise(value: 1)
let p2 = Promise<Int>(error: TestError.general(message: "Test error."))

//Async Promise
let p3 = Promise<String> { (resolver) in
  let url = URL(string: "https://api.ipify.org")
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
}

```
