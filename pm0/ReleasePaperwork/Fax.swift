//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation




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

import PhaxioiOS


@objc class PM0PhaxioFaxDelegate:NSObject,FaxDelegate{
  func sentFax(_ success:Bool, andResponse json:[AnyHashable : Any]){
    print("Success:\(success) responsse\(json)")
  }
}

var useOldPhaxioObjc = false

let faxDelegate = PM0PhaxioFaxDelegate()
var fax:Fax = Fax.init(fax:()) //Objc Api, sigh

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
     // let stringObj = String(data:data,encoding:.utf8)!
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


      if(useOldPhaxioObjc)
      {
        PhaxioAPI.setAPIKey(key, andSecret: secret)
        fax = Fax.init(fax: ())
        fax.delegate = faxDelegate
        fax.to_phone_numbers = [toNumber]
        let fixedFileName = Bundle.main.resourcePath! + "/" + documentPaths.first!
        fax.file = readFile(fileName: fixedFileName) // FAX.FILE assumes JPEG
        fax.send()
        return;
      }


      var req = URLRequest(url: URL(string:uri)!)
      req.httpMethod = "POST"


      let boundaryHeader = "------------------------2b1b5a3d9d8f447f"
      let boundary = "--"+boundaryHeader

      //define the multipart request type

      req.setValue("multipart/form-data; boundary=\(boundaryHeader)", forHTTPHeaderField: "Content-Type")

      let base64OfKeySecret = "\(key):\(secret)".toBase64()
      req.setValue("Basic \(base64OfKeySecret)", forHTTPHeaderField: "Authorization")
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
        Content-Type: application/octet-stream

        \(fileContents.base64EncodedString())
        """
      }.joined(separator: "\n")
      req.httpBody = (body1+body2+"\n"+boundary+"--").replacingOccurrences(of:"\n",with:"\r\n").data(using: .utf8)



      //todo make this pass the post params with tth efilename
      let task2 = URLSession.shared.dataTask(with: req)   { (data, response, error) in
        dump(("***",data,response,error,"***"))
        debugPrint("=-----1")
        debugPrint(String(data:req.httpBody!,encoding:.utf8) ?? "")
        debugPrint("=-----2")
        debugPrint("Response Code: \(response?.description ?? "noResp")")
      }
      task2.resume()


    }  catch let error as NSError {
      print(error.localizedDescription)
    }
  }

  task.resume()
}


