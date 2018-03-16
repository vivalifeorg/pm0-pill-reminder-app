//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation


import AWSLambda

func generateBoundaryString() -> String {
  return "Boundary-\(NSUUID().uuidString)"
}

func readFile(fileName: String) -> Data{
  return try! NSData.init(contentsOfFile:fileName, options:[]) as Data
}

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
      //print(stringObj)

      guard let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as?  [String:Any] else{
        print("Can't deserialize")
        return
      }


      guard let uri = jsonSerialized["uri"] as? String,
            let params = jsonSerialized["postParams"] as? [String],
            //let templatedTerms = jsonSerialized["templatedTerms"] as? [String],
            let key = jsonSerialized["key"] as? String,
            let secret = jsonSerialized["secret"] as? String
        //let vlToken = jsonSerialized["vlToken"] as? String
        else {
          print("Missing expected params")
          return
      }

      var req = URLRequest(url: URL(string:uri)!)
      req.httpMethod = "POST"


      let boundary = "---------------------------faxity_faxfaxfaxfax_faxity"

      //define the multipart request type

      req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")


      req.setValue("\(key):\(secret)", forHTTPHeaderField: "Authorization")
      let theFaxNumber = toNumber
      let theFilePath = "/obviouslyFake"
      let preppedParams = params.map{
        $0.replacingOccurrences(of: "{{{filepath}}}",
                                with: theFilePath).replacingOccurrences(of: "{{{faxnumber}}}", with: theFaxNumber)
      }

      let body1 = preppedParams.flatMap{
        let splitParams = $0.split(separator:"=")
        let param1 = splitParams.first!

        if param1 == "file[]" {return ""}

        let rest = String(splitParams.dropFirst().joined())
        let boundaryAndTextType = """
        \(boundary)
        Content-Disposition: form-data; name=\"\(param1)\"

        \(rest)

        """
        return boundaryAndTextType
      }.joined()

      let body2 = documentPaths.flatMap{
        let fixedFileName = Bundle.main.resourcePath! + "/" + $0
        let fileContents = readFile(fileName: fixedFileName)
        return """
        \(boundary)
        Content-Disposition: form-data; name=\"file\"; filename=\"\($0)\"

        \(fileContents.base64EncodedString())

        """
      }.joined(separator: "\n")
      req.httpBody = (body1+body2+"\n"+boundary).data(using: .utf8)



      //todo make this pass the post params with tth efilename
      let task2 = URLSession.shared.dataTask(with: req)   { (data, response, error) in
        dump(("***",data,response,error,"***"))
        debugPrint("=-----1")
        debugPrint("Response Code: \(response?.description ?? "noResp")")
        debugPrint("=-----2")
        debugPrint(String(data:req.httpBody!,encoding:.utf8) ?? "")
      }
      task2.resume()


    }  catch let error as NSError {
      print(error.localizedDescription)
    }
  }

  task.resume()
}


