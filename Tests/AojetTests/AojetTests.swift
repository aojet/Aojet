//
//  AojetTests.swift
//  AojetTests
//
//  Created by Qihe Bian on 10/7/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

import XCTest
@testable import Aojet

class AojetTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testCompletedPromise() {
    let p = Promise<Int>(value: 2)
    let completeExpectation = self.expectation(description: "immediate complete")
    p.then { result in
      XCTAssert(result! == 2)
      completeExpectation.fulfill()
    }
    waitForExpectations(timeout: 2, handler: nil)
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
