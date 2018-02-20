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

func packagesMatching(_ search:String)->[[String:String]]{
  let query = "SELECT PROPRIETARYNAME,NONPROPRIETARYNAME,PRODUCTNDC,DOSAGEFORMNAME,ACTIVE_NUMERATOR_STRENGTH,ACTIVE_INGRED_UNIT,* FROM RawProductPackage where NONPROPRIETARYNAME LIKE ? Or PROPRIETARYNAME LIKE ? OR NONPROPRIETARYNAME LIKE ? or PROPRIETARYNAME LIKE ?  order by length(PROPRIETARYNAME) "
  let searchSpace = "% \(search)%"
  let statement = try! fdaDbConnection.prepare(query)
  debugPrint("searchspace: \(searchSpace)")
  let results = try! statement.run(search, search, searchSpace, searchSpace)

  let coercedToString = results.map{ $0.map{ $0 as? String ?? ""}}

  let items:[[String:String]] = coercedToString.map{ package in
    let dict:[String:String] = ["PROPRIETARYNAME":fixDrugName(package[0]),
      "NONPROPRIETARYNAME":fixDrugName(package[1]),
      "PRODUCTNDC":package[2],
    "DOSAGEFORMNAME":fixForm(package[3]),
    "ACTIVE_NUMERATOR_STRENGTH":fixNumerator(package[4]),
    "ACTIVE_INGRED_UNIT":fixUnit(package[5]),
    "z_*":String(describing:package.dropFirst(6)) ]
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



