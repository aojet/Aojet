//
//  ImmediateDispatcher.swift
//  Aojet
//
//  Created by Qihe Bian on 6/6/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

protocol ImmediateDispatcher {

  func dispatchNow(runnable: Runnable)

}
