//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation


import AWSLambda

func sendFax(documentPaths:[String],completion:@escaping (Bool,String)->()){
  let lambdaInvoker = AWSLambdaInvoker.default()
  lambdaInvoker.invokeFunction("customer-vivalife-temp-fax-vendor-phaxio-1", jsonObject: [])
    .continueWith(block: {(task:AWSTask<AnyObject>) -> Any? in
      guard task.error == nil else{
        let errorstr = task.error?.localizedDescription ?? "Unknown failure"
        completion(false,errorstr)
        return nil
      }

      guard let JSONDictionary = task.result as? NSDictionary else {
        completion(false,"It failed")
        return nil
      }

      print("Result: \(JSONDictionary)")
      completion(true,"It worked!")

      // Handle response in task.result
      return nil
    })
}


