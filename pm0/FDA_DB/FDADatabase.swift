//
//  FDADatabase.swift
//  pm0
//
//  Created by Michael Langford on 2/12/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation
import SQLite


struct ProductPackaging:Decodable{
  let productName: String
  let ndcPackageCode: String
  let packageDescription: String
}

//let drugList = loadDrugDB()

extension Array where Element : Hashable {
  var unique: [Element] {
    return Array(Set(self))
  }
}

func packagesMatching(_ search:String)->[[String:String]]{
  let query = "SELECT PROPRIETARYNAME,NONPROPRIETARYNAME,PRODUCTNDC,DOSAGEFORMNAME FROM RawProductPackage where NONPROPRIETARYNAME LIKE ? Or PROPRIETARYNAME LIKE ? OR NONPROPRIETARYNAME LIKE ? or PROPRIETARYNAME LIKE ?  order by length(PROPRIETARYNAME)"
  let searchSpace = "% \(search)%"
  let statement = try! fdaDbConnection.prepare(query)
  debugPrint("searchspace: \(searchSpace)")
  let results = try! statement.run(search, search, searchSpace, searchSpace)

  let items:[[String:String]] = results.map{ package in
    let dict:[String:String] = ["PROPRIETARYNAME":package[0] as? String ?? "",
      "NONPROPRIETARYNAME":package[1] as? String ?? "",
      "PRODUCTNDC":package[2] as? String ?? "",
    "DOSAGEFORMNAME":package[3] as? String ?? ""]
    return dict
  }
  return [[String:String]](items)
}


func namesMatching(_ search:String)->[String]{
  let results = packagesMatching(search)
  debugPrint(results.last ?? "")
  return Array<String>(results.map{"\($0["PROPRIETARYNAME"] ?? "") (\($0["NONPROPRIETARYNAME"] ?? ""))"})
}

fileprivate let fdaDbConnection = {return try! Connection(Bundle.main.path(forResource: "fda_drugs", ofType: "db")!)}()

fileprivate let productPackageTable = {
  return try! fdaDbConnection.prepare(Table("ProductPackage"))
}()

fileprivate func loadDrugDB()->[ProductPackaging]{
  return productPackageTable.map { row in
    return try! row.decode()
  }
}



