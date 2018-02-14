//
//  pm0Tests.swift
//  pm0Tests
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import XCTest
@testable import pm0

class pm0Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDBSearch() {
      let matches = namesMatching("Tyl")
      XCTAssert(matches.count > 0, "Not finding basic drugs")
    }

  func testDBFrontBackSearch() {
    let matches = namesMatching("Tyl")
    var isChildrensThere = false
    for match in matches{
      print("--\(match)\n")
      if match.range(of:"Childrens Tylenol") != nil {
        isChildrensThere = true
      }
    }
    XCTAssert(isChildrensThere,"Not finding Childrens Tylenol, so front search doesn't work")

  }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
