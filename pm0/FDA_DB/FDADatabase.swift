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

func namesMatching(_ search:String)->[String]{
  let productName = Expression<String>("productName")
  print("Searching for '\(search)'")
  let query = Table("ProductPackage").filter(productName.like("\(search)%"))
  let queryResults = try? fdaDbConnection.prepare( query )
  return  queryResults?.map{$0[productName]}.unique ?? []
}


func packagesMatching(_ search:String)->[ProductPackaging]{
  let productName = Expression<String>("productName")
  let ndcPackageCode = Expression<String>("ndcPackageCode")
  let packageDescription = Expression<String>("packageDescription")
  //return try! fdaDbConnection.run(Table("ProductPackage").filter(productName.like("%\(search)%")))

  print("Searching for '\(search)'")
  let query = Table("ProductPackage").filter(productName.like("%\(search)%"))
  let queryResults = try? fdaDbConnection.prepare( query )
  for package in queryResults! {
    print("Match: \(package[productName]), ndcPackageCode: \(package[ndcPackageCode]),packageDescription: \(package[packageDescription])")

  }
  return  []
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



