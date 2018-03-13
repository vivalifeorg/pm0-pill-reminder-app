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

func fixUnits(_ unfixed:String)->[String]{
  if unfixed.contains(";"){
    return unfixed.split(separator: ";").map{ fixUnit(String($0))}
  }else{
    return [fixUnit(unfixed)]
  }
}

func fixUnit(_ unfixed:String)->String{
  switch unfixed{
  case "mg/1":
    return "mg"
  default:
    return unfixed
  }
}

func fixNumerators(_ unfixed:String)->[String]{
  switch unfixed{
  default:
    if unfixed.contains(";"){
      return unfixed.split(separator: ";").map{String($0)}
    }
    return [unfixed]
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


struct MedicationPackage:Codable{
  let proprietaryName:String
  let nonProprietaryName:String
  let dosageForname:String
  let activeNumerator:String
  let activeIngrediantUnit:String

}

extension MedicationPackage{
  init(package:[String]){
    proprietaryName = fixDrugName(package[0])
    nonProprietaryName = fixDrugName(package[1])
    dosageForname = fixForm(package[2])
    activeNumerator = fixNumerators(package[3]).first!
    activeIngrediantUnit = fixUnits(package[4]).first!
  }
}

func matchingMedications(_ search:String)->[MedicationPackage]{
  let drugs = rawMatch(search)
  return drugs.map{MedicationPackage(package:$0)}
}

func pillSizesMatch(name:String, partial:String)->[MedicationPackage]{
  return matchingMedications(name)
}

fileprivate let fdaDbConnection = {try! Connection(Bundle.main.path(forResource: "fda_drugs", ofType: "db")!)}()




