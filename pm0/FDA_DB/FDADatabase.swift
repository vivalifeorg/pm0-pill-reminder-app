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
