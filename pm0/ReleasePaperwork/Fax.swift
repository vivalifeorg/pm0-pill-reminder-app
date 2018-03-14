//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation


import AWSLambda

func sendFax(toNumber:String, documentPaths:[String],completion:@escaping (Bool,String)->()){
  let faxEndpoint = "https://ifoamvnu09.execute-api.us-east-1.amazonaws.com/staging/fax/credentials"
  let task = URLSession.shared.dataTask(with: URL(string:faxEndpoint)!) { (data, response, error) in

    guard let data = data else{
      if let error = error {
        print(error.localizedDescription)
      }
      return
    }

    do {
        // Convert the data to JSON
      let stringObj = String(data:data,encoding:.utf8)!
      print(stringObj)

      guard let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as?  [String:Any] else{
        print("Can't deserialize")
        return
      }


      guard let uri = jsonSerialized["uri"] as? String,
            let params = jsonSerialized["postParams"] as? [String],
            let templatedTerms = jsonSerialized["templatedTerms"] as? [String],
            let key = jsonSerialized["key"] as? String,
            let secret = jsonSerialized["secret"] as? String ,
        let vlToken = jsonSerialized["vlToken"] as? String else {
          print("Missing expected params")
          return
      }

      var req = URLRequest(url: URL(string:uri)!)
      req.httpMethod = "POST"
      req.setValue("Basic \(key):\(secret)", forHTTPHeaderField: "Authorization")
      let theFaxNumber = toNumber
      let theFilePath = "/obviouslyFake"
      let preppedParams = params.map{
        $0.replacingOccurrences(of: "filepath",
                                with: theFilePath).replacingOccurrences(of: "faxnumber", with: theFaxNumber)
      }
      let body = preppedParams.joined(separator: "\n")
      req.httpBody = body.data(using: .utf8)

      //todo make this pass the post params with tth efilename
      let task2 = URLSession.shared.dataTask(with: req)   { (data, response, error) in
        debugPrint(data,response,error)
        debugPrint("=-----")
        dump(req)
      }
      task2.resume()


    }  catch let error as NSError {
      print(error.localizedDescription)
    }
  }

  task.resume()
}


