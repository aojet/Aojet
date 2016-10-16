//
//  LogRuntime.swift
//  Aojet
//
//  Created by Qihe Bian on 16/10/5.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol LogRuntime {

  func warning(tag: String, message: String)
  func error(tag: String, error: Error)
  func debug(tag: String, message: String)
  func verbose(tag: String, message: String)

}
