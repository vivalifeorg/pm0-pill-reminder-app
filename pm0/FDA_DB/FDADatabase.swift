//
//  FDADatabase.swift
//  pm0
//
//  Created by Michael Langford on 2/12/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation
import SQLite


struct ProductPackaging{
  let productName: String
  let ndcPackageCode: String
  let packageDescription: String
}



let drugList = loadDrugDB()
func loadDrugDB()->[ProductPackaging]{
  let db = try! Connection(Bundle.main.path(forResource: "fda_drugs", ofType: "db")!)
  let productPackages = Table("ProductPackage")
  let productName = Expression<String>("productName")
  let ndcPackageCode = Expression<String>("ndcPackageCode")
  let packageDescription = Expression<String>("packageDescription")
  return try! db.prepare(productPackages).map{ packageInfo in
    ProductPackaging(productName:packageInfo[productName],
                     ndcPackageCode:packageInfo[ndcPackageCode],
                     packageDescription:packageInfo[packageDescription])

  }
}



