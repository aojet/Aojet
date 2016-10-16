//
//  AskInternalRequest.swift
//  Aojet
//
//  Created by Qihe Bian on 6/7/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

struct AskInternalRequest {
  let message: Any
  let future: PromiseResolver<Any>

  init(message: Any, future: PromiseResolver<Any>) {
    self.message = message
    self.future = future
  }

}
