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

func dropVirtualTable(){

  let cv_query = "drop table if exists fastproductpackages"
  let cv_statement = try! fdaDbConnection.prepare(cv_query)
  try! cv_statement.run()

}

func buildVirtualTableIfNeeded(){
  //make it if needed
  let cv_query = "create virtual table if not exists fastproductpackages using fts5(PRODUCTID,NONPROPRIETARYNAME,PROPRIETARYNAME)"
  try! fdaDbConnection.prepare(cv_query).run()

  //leave if it already exists and has stuff
  let count = try! fdaDbConnection.prepare("SELECT * from fastproductpackages").scalar() as? Int64 ?? 0
  guard count == 0 else {
    return
  }

  //add stuff if needed
  let query = "insert into fastproductpackages select PRODUCTID,NONPROPRIETARYNAME,PROPRIETARYNAME from rawproductpackage"
  let statement = try! fdaDbConnection.prepare(query)
  try! statement.run()
}

we have to implement

http://www.sqlite.org/fts3.html#the_compress_and_uncompress_options

to do what

https://blog.kapeli.com/sqlite-fts-contains-and-suffix-matches

does but for prefixes

func rawMatch(_ search:String)->[[String]]{
  let drugs = try! fdaDbConnection.prepare(
    "SELECT upper(PROPRIETARYNAME),upper(NONPROPRIETARYNAME),DOSAGEFORMNAME,ACTIVE_NUMERATOR_STRENGTH,ACTIVE_INGRED_UNIT FROM RawProductPackage where productid in (SELECT productid from fastproductpackages where fastproductpackages match ? order by rank limit 100)").run("'\(search)'*")
  return drugs.map{ $0.map{ $0 as? String ?? ""}}
}

func packagesMatchingInVT(_ search:String)->[[String:String]]{
  buildVirtualTableIfNeeded()
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
  let search = name
  let query = "SELECT DISTINCT upper(PROPRIETARYNAME),upper(NONPROPRIETARYNAME),DOSAGEFORMNAME,DOSAGEFORMNAME,ACTIVE_NUMERATOR_STRENGTH,ACTIVE_INGRED_UNIT FROM RawProductPackage where NONPROPRIETARYNAME LIKE ? Or PROPRIETARYNAME LIKE ? OR NONPROPRIETARYNAME LIKE ? or PROPRIETARYNAME LIKE ?  order by PROPRIETARYNAME" //took out PRODUCT NDC

  let searchSpace = "% \(search)%"
  let statement = try! fdaDbConnection.prepare(query)
  debugPrint("searchspace: \(searchSpace)")
  let results = try! statement.run(search, search, searchSpace, searchSpace)

  let coercedToString = results.map{ $0.map{ $0 as? String ?? ""}}

  let items:[[String:String]] = coercedToString.map{ package in
    let dict:[String:String] = ["PROPRIETARYNAME":fixDrugName(package[0]),
                                "NONPROPRIETARYNAME":fixDrugName(package[1]),
                                //"PRODUCTNDC":package[2],
      "DOSAGEFORMNAME":fixForm(package[3]),
      "ACTIVE_NUMERATOR_STRENGTH":fixNumerator(package[4]),
      "ACTIVE_INGRED_UNIT":fixUnit(package[5]) ]
    return dict
  }
  return [[String:String]](items)
}

func namesMatching(_ search:String)->[String]{
  let results = packagesMatchingInVT(search)
  //debugPrint(results.last ?? "")
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



