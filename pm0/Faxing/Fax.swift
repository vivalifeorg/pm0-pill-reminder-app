//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation


func sendFax(toNumber:String, documentPaths:[String],completion:@escaping (Bool,String)->()){
  phaxioObjcFaxService.sendFaxUsingService(toNumber:toNumber,
                                           documentPaths:documentPaths,
                                           completion:completion)
}


protocol FaxServiceProvider{
  func sendFax(authentication:FaxService.Credentials,
               otherInfo:FaxService.OtherSenderInfo,
               toNumber:String,
               documentPaths:[String],
               completion:@escaping (Bool,String)->())

}

struct FaxService{
  struct Credentials {
    let key:String
    let secret:String
  }
  struct OtherSenderInfo {
    let uri:String
    let params:[String]
  }
  let provider:FaxServiceProvider

  static func fetchFaxCredentials(toNumber:String,
                                  documentPaths:[String],
                                  completion:@escaping (Bool, String, FaxService.Credentials?, FaxService.OtherSenderInfo?)->()){
    let faxEndpoint = "https://ifoamvnu09.execute-api.us-east-1.amazonaws.com/staging/fax/credentials"
    let task = URLSession.shared.dataTask(with: URL(string:faxEndpoint)!) { (data, response, error) in

      guard let data = data else{
        if let error = error {
          print(error.localizedDescription)
        }
        return
      }

      guard let parsed = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) else {
        completion(false, "Can't parse json", nil, nil)
        return
      }


      guard let jsonSerialized = parsed as? [String:Any] else{
        completion(false, "Can't deserialize answer from credential service", nil, nil)
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
          completion(false, "Missing Params", nil, nil)
          return
      }
      completion(true,
                 "It worked",
                 FaxService.Credentials(key:key, secret:secret),
                 FaxService.OtherSenderInfo(uri: uri, params: params))

    }
    task.resume()
  }

  func sendFaxUsingService(toNumber:String, documentPaths:[String],completion:@escaping (Bool,String)->()){
    FaxService.fetchFaxCredentials(
      toNumber:toNumber,
      documentPaths:documentPaths ){ success, errorInfo, creds, other in

        guard let creds = creds, let other = other, success == true else {
          completion(false, errorInfo)
          return

        }

        self.provider.sendFax(
          authentication: creds,
          otherInfo:other,
          toNumber: toNumber,
          documentPaths: documentPaths,
          completion:completion)
    }
  }
}



func generateBoundaryString() -> String {
  return "Boundary-\(NSUUID().uuidString)"
}

extension String {

  func fromBase64() -> String? {
    guard let data = Data(base64Encoded: self) else {
      return nil
    }

    return String(data: data, encoding: .utf8)
  }

  func toBase64() -> String {
    return Data(self.utf8).base64EncodedString()
  }
}

func readFile(fileName: String) -> Data{
  return try! NSData.init(contentsOfFile:fileName, options:[]) as Data
}



