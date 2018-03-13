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
        let matches = packagesMatchingInVT("Tylenol")
        XCTAssert(matches.count > 0, "Not finding basic drugs")
      
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

  func testDBRawT(){
    var matches:[[String]] = []
    buildVirtualTableIfNeeded()
    self.measure{
      matches = rawMatch("Tyl")
    }
    debugPrint(matches)
  }


  func testDBSearchSpeed(){
    buildVirtualTableIfNeeded()
    self.measure{
      _ = packagesMatchingInVT("Tylenol")
    }
  }
    
}
