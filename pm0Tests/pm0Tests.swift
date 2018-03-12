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
      self.measure{
        let matches = namesMatching("Tylenol")
        XCTAssert(matches.count > 0, "Not finding basic drugs")
      }
    }

  func testDBFrontBackSearch() {
    let matches = namesMatching("Tyl*")
    var isChildrensThere = false
    for match in matches{
      if match.range(of:"Childrens Tylenol") != nil {
        isChildrensThere = true
        break
      }
    }
    XCTAssert(isChildrensThere,"Not finding Childrens Tylenol, so front search doesn't work")

  }

  func testDBBuildVirtualTable(){
    dropVirtualTable()
    buildVirtualTableIfNeeded()
  }

  func testDBRaw(){
    buildVirtualTableIfNeeded()
    self.measure{
      _ = rawMatch("Tylenol")
    }
  }

  func testDBSearchSpeed(){
    buildVirtualTableIfNeeded()
    self.measure{
      _ = packagesMatchingInVT("Tylenol")
    }
  }
    
}
