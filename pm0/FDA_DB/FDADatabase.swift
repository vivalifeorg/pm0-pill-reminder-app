//
//  FDADatabase.swift
//  pm0
//
//  Created by Michael Langford on 2/12/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation

struct Product{
  let productName:String
  let availablePackagingOptions:[ProductPackaging]
}

struct ProductPackaging{
  let productName: String
  let ndcPackageCode: String
  let packageDescription: String
  let nominalPotency: Int
}


let db = try Connection("path/to/db.sqlite3")

let users = Table("users")
let id = Expression<Int64>("id")
let name = Expression<String?>("name")
let email = Expression<String>("email")
