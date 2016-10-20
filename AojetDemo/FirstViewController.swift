//
//  FirstViewController.swift
//  AojetDemo
//
//  Created by Qihe Bian on 10/7/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import UIKit
import Aojet

class FirstViewController: UIViewController {

  var demoActor: ActorRef? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func onTap(_ sender: AnyObject) {
    let actorSystem = ActorSystem.system
    actorSystem.traceInterface = ActorTrace()
    let actor = try! actorSystem.actorOf(path: "testActor", creator: AnyActorCreator{ () -> Actor in
      return SomeActor()
    })

    demoActor = actor
    let p1: Promise<String> = actor.ask(message: SomeActor.DoSomething(object: "An object for ask"))
    p1.then { (res) in
      print("Ask response:\(res)")
      }.failure { (error) in
        print("Ask error:\(error)")
    }

    actor.send(message: "An string")
    actor.send(message: SomeActor.DoSomething(object: "Another object"))

//    if demoActor == nil {
//      demoActor = DemoActor.create()
//    }
//    let p: Promise<String> = demoActor!.ask(message: DemoActor.InitActor())
//    p.then {
//      print($0)
//    }
//    DispatchQueue.global().async {
//    ThreadDispatcher.pushDispatcher { (runnable: Runnable) in
////      if Thread.current == Thread.main {
////        runnable.run()
////      } else {
//        DispatchQueue.main.async {
//          runnable.run()
//        }
////      }
//    }
//    }
////    var resolver: PromiseResolver<Int>? = nil
//    let pB = Promise<Int> { (resolver1) in
////      resolver = resolver1
//    }.changeDispatcher({ (runnable) in
////      DispatchQueue(label: "dispatcher").async {
//        runnable.run()
////      }
//    }).then { (i) in
//      print("a: i: \(i) thread: \(Thread.current)")
//    }
//    let p = Promise<String> { (resolver) in
////      DispatchQueue(label: "test").async {
//        print("test")
//        resolver.result("hi")
////      }
////      usleep(1000000)
//    }
//    let p1 = p.map({ (r) -> Int? in
//      print("r: \(r) thread: \(Thread.current)")
//      if r != nil {
//        return 1
//      } else {
//        return 0
//      }
//    })
//    p1.then { (i) in
//      print("i: \(i) thread: \(Thread.current)")
//    }.pipeTo(resolver: PromiseResolver(promise: pB))
//
//    let pC = Promise<Void> { (resolver) in
//      resolver.result(())
//    }
  }


}

