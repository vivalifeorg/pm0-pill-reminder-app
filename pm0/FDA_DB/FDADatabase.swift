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


extension Array where Element : Hashable {
  var unique: [Element] {
    return Array(Set(self))
  }
}



func fixUnit(_ unfixed:String)->String{
  switch unfixed{
  case "mg/1":
    return "mg"
  default:
    if unfixed.contains(";"){
      return ""
    }
    return unfixed
  }
}

func fixNumerator(_ unfixed:String)->String{
  switch unfixed{
  default:
    if unfixed.contains(";"){
      return ""
    }
    return unfixed
  }
}

func fixForm(_ unfixed:String)->String{
  switch unfixed{
  default:
    return unfixed.lowercased().localizedCapitalized
  }
}

func fixDrugName(_ unfixed:String)->String{
  switch unfixed{
  default:
    let tokens:[String] = unfixed.split(separator: " ").map{String($0)}
    let words:[String] = tokens.map{
      if $0.count > 3 {
        return $0.localizedCapitalized
      } else {
        return $0
      }
    }

    guard let firstWord = words.first else{
      return ""
    }
    return words.dropFirst().reduce(firstWord){$0 + " " + $1 }
  }
}


let productTableName = "Product"

fileprivate var cachedNameSearchStatement:Statement?
fileprivate var nameSearchStatement:Statement{
  if cachedNameSearchStatement == nil {
    let rawMatchQuery =
  "SELECT PROPRIETARYNAME, NONPROPRIETARYNAME, DOSAGEFORMNAME, ACTIVE_NUMERATOR_STRENGTH, ACTIVE_INGRED_UNIT,  upper(PROPRIETARYNAME||NONPROPRIETARYNAME) AS nameconcat FROM \(productTableName) where nameconcat like '%'||@medicationName||'%'"
    cachedNameSearchStatement = try! fdaDbConnection.prepare(rawMatchQuery)
  }
  return cachedNameSearchStatement!
}

func rawMatch(_ search:String)->[[String]]{
  guard search.count >= 3 else{
    debugPrint("String too short, aborting")
    return []
  }
  
  debugPrint("Searching for: \(search)")
  let drugs = try! nameSearchStatement.run(["@medicationName":search])
  return drugs.map{ $0.map{ $0 as? String ?? ""}}
}

func matchingMedications(_ search:String)->[[String:String]]{
  let drugs = rawMatch(search)
  let items:[[String:String]] = drugs.map{ package in
    return[
      "PROPRIETARYNAME":fixDrugName(package[0]),
      "NONPROPRIETARYNAME":fixDrugName(package[1]),
      "DOSAGEFORMNAME":fixForm(package[2]),
      "ACTIVE_NUMERATOR_STRENGTH":fixNumerator(package[3]),
      "ACTIVE_INGRED_UNIT":fixUnit(package[4])
    ]
  }
  return [[String:String]](items)
}

func pillSizesMatch(name:String, partial:String)->[[String:String]]{
  return matchingMedications(name)
}

fileprivate let fdaDbConnection = {try! Connection(Bundle.main.path(forResource: "fda_drugs", ofType: "db")!)}()

fileprivate let productPackageTable = {
  return try! fdaDbConnection.prepare(Table("ProductPackage"))
}()

fileprivate func loadDrugDB()->[ProductPackaging]{
  return productPackageTable.map { row in
    return try! row.decode()
  }
}



