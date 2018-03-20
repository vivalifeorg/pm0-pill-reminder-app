//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation

import PhaxioSwiftAlamofire
import Alamofire


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




extension String{
  var CRLFified:String{
    return replacingOccurrences(of:"\n",with:"\r\n")
  }
}
var useOldPhaxioObjc = true
var usePhaxioSwiftAlamofire = false


func mimeTypeName(_ filename:String)->String{
  switch String(filename.split(separator:".").last ?? "").lowercased(){
  case "jpg":
    return "image/jpg"
  case "png":
    return "image/png"
  case "pdf":
    return "application/pdf"
  default:
    return "application/octet"
  }
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

struct PhaxioObjcFaxProvider:FaxServiceProvider{

  func sendFax(authentication:FaxService.Credentials,
               otherInfo:FaxService.OtherSenderInfo,
               toNumber:String,
               documentPaths:[String],
               completion:@escaping (Bool,String)->()){

    PhaxioAPI.setAPIKey(authentication.key, andSecret: authentication.secret)
    let fax = Fax()!
    fax.delegate = apiDelegate
    fax.to_phone_numbers = [toNumber]
    let shortFilename = documentPaths.first!
    let mimeType = mimeTypeName(shortFilename)
    let fixedFileName = Bundle.main.resourcePath! + "/" + shortFilename

    debugPrint("\(shortFilename) is a \(mimeType)")
    fax.files = [
      FaxFile(data:readFile(fileName: fixedFileName), name:shortFilename, mimeTypeName:mimeType)
    ]
    // fax.files = [readFile(fileName: fixedFileName)] // FAX.FILE assumes JPEG
    fax.send()
  }


  let apiDelegate: PhaxioObjcApiDelegate
  init(){
    apiDelegate = PhaxioObjcApiDelegate()
    apiDelegate.callbackDelegate = doneSending
  }

  func doneSending(success:Bool,json:[AnyHashable : Any]) {

  }


  @objc class PhaxioObjcApiDelegate:NSObject,FaxDelegate{
    func sentFax(_ success:Bool, andResponse json:[AnyHashable : Any]){
      print("Success:\(success) responsse\(json)")
      callbackDelegate(success, json)
    }

    var callbackDelegate:((Bool,[AnyHashable : Any])->())! = nil
  }
}


/*


 func sendFax(toNumber:String, documentPaths:[String],completion:@escaping (Bool,String)->()){


 if(useOldPhaxioObjc)
 {
 PhaxioAPI.setAPIKey(key, andSecret: secret)
 fax = Fax()
 fax.delegate = faxDelegate
 fax.to_phone_numbers = [toNumber]
 let shortFilename = documentPaths.first!
 let mimeType = mimeTypeName(shortFilename)
 let fixedFileName = Bundle.main.resourcePath! + "/" + shortFilename

 debugPrint("\(shortFilename) is a \(mimeType)")
 fax.files = [
 FaxFile(data:readFile(fileName: fixedFileName), name:shortFilename, mimeTypeName:mimeType)
 ]
 // fax.files = [readFile(fileName: fixedFileName)] // FAX.FILE assumes JPEG
 fax.send()
 return;
 }

 if usePhaxioSwiftAlamofire{
 //(to: [String], direction: PhaxioDirection_sendFax? = nil, file: [URL]? = nil, contentUrl: [String]? = nil, headerText: String? = nil, batchDelay: Int? = nil, batchCollisionAvoidance: Bool? = nil, callbackUrl: String? = nil, cancelTimeout: Int? = nil, callerId: String? = nil, testFail: PhaxioTestFail_sendFax? = nil, completion: @escaping ((_ data: PhaxioSendFaxResponse?,_ error: Error?) -> Void))
 let fixedFileName = Bundle.main.resourcePath! + "/" + documentPaths.first!
 let fileURL = URL(fileURLWithPath:fixedFileName)
 let sessionManager = Alamofire.SessionManager.default
 let base64OfKeySecret = "\(key):\(secret)".toBase64()
 sessionManager.session.configuration.httpAdditionalHeaders = ["Authorization":"Basic \(base64OfKeySecret)"]
 let protectionSpace = URLProtectionSpace.init(host: "api.phaxio.com",
 port: 443,
 protocol: "https",
 realm: nil,
 authenticationMethod: nil)
 let userCredential = URLCredential(user: key,
 password: secret,
 persistence: URLCredential.Persistence.forSession)

 URLCredentialStorage.shared.setDefaultCredential(userCredential, for: protectionSpace)
 PhaxioSwiftAlamofireAPI.credential = userCredential
 PhaxioSwiftAlamofireAPI.customHeaders =  ["Authorization":"Basic \(base64OfKeySecret)"]

 DefaultAPI.sendFax(to: [toNumber], file: [fileURL], headerText: "Sent via VivaLife"){
 (_ data: PhaxioSendFaxResponse?,_ error: Error?) in
 debugPrint("send fax completion: ")
 debugPrint("error: \(error?.localizedDescription)")
 }

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
 let preppedParams = params.map{
 $0.replacingOccurrences(of: "{{{filepath}}}",
 with: "none").replacingOccurrences(of: "{{{faxnumber}}}", with: theFaxNumber)
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


 let body2Datas:[Data] = documentPaths.flatMap{
 let fixedFileName = Bundle.main.resourcePath! + "/" + $0
 let fileContents = readFile(fileName: fixedFileName)
 let mimeType = "image/jpg"
 let image = UIImage(data:fileContents)!
 debugPrint("data: \(image)")
 var info = """
 \(boundary)
 Content-Disposition: form-data; name=\"file\"; filename=\"\($0)\"
 Content-Type: \(mimeType)

 """.CRLFified
 var infoData = info.data(using:.utf8)!

 infoData.append(fileContents)
 infoData.append("\r\n".data(using:.utf8)!)

 return infoData
 }

 let body1Data = body1.CRLFified.data(using:.utf8)!
 let endData = ("\r\n"+boundary+"--").data(using:.utf8)!
 var bodyData = Data()
 bodyData.append(body1Data)
 for d in body2Datas{
 bodyData.append(d)
 }
 bodyData.append(endData)

 req.httpBody = bodyData
 //(body1+body2+"\n"+boundary+"--").replacingOccurrences(of:"\n",with:"\r\n").data(using: .utf8)



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


 */

let phaxioObjc = FaxService(provider: PhaxioObjcFaxProvider())


func sendFax(toNumber:String, documentPaths:[String],completion:@escaping (Bool,String)->()){
  phaxioObjc.sendFaxUsingService(toNumber:toNumber,
                                 documentPaths:documentPaths,
                                 completion:completion)
  return;
/*
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
        fax = Fax()
        fax.delegate = faxDelegate
        fax.to_phone_numbers = [toNumber]
        let shortFilename = documentPaths.first!
        let mimeType = mimeTypeName(shortFilename)
        let fixedFileName = Bundle.main.resourcePath! + "/" + shortFilename

        debugPrint("\(shortFilename) is a \(mimeType)")
        fax.files = [
          FaxFile(data:readFile(fileName: fixedFileName), name:shortFilename, mimeTypeName:mimeType)
        ]
        // fax.files = [readFile(fileName: fixedFileName)] // FAX.FILE assumes JPEG
        fax.send()
        return;
      }

      if usePhaxioSwiftAlamofire{
        //(to: [String], direction: PhaxioDirection_sendFax? = nil, file: [URL]? = nil, contentUrl: [String]? = nil, headerText: String? = nil, batchDelay: Int? = nil, batchCollisionAvoidance: Bool? = nil, callbackUrl: String? = nil, cancelTimeout: Int? = nil, callerId: String? = nil, testFail: PhaxioTestFail_sendFax? = nil, completion: @escaping ((_ data: PhaxioSendFaxResponse?,_ error: Error?) -> Void))
        let fixedFileName = Bundle.main.resourcePath! + "/" + documentPaths.first!
        let fileURL = URL(fileURLWithPath:fixedFileName)
        let sessionManager = Alamofire.SessionManager.default
        let base64OfKeySecret = "\(key):\(secret)".toBase64()
        sessionManager.session.configuration.httpAdditionalHeaders = ["Authorization":"Basic \(base64OfKeySecret)"]
        let protectionSpace = URLProtectionSpace.init(host: "api.phaxio.com",
                                                      port: 443,
                                                      protocol: "https",
                                                      realm: nil,
                                                      authenticationMethod: nil)
        let userCredential = URLCredential(user: key,
                                           password: secret,
                                           persistence: URLCredential.Persistence.forSession)

        URLCredentialStorage.shared.setDefaultCredential(userCredential, for: protectionSpace)
        PhaxioSwiftAlamofireAPI.credential = userCredential
        PhaxioSwiftAlamofireAPI.customHeaders =  ["Authorization":"Basic \(base64OfKeySecret)"]
        
        DefaultAPI.sendFax(to: [toNumber], file: [fileURL], headerText: "Sent via VivaLife"){
          (_ data: PhaxioSendFaxResponse?,_ error: Error?) in
          debugPrint("send fax completion: ")
          debugPrint("error: \(error?.localizedDescription)")
        }

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
      let preppedParams = params.map{
        $0.replacingOccurrences(of: "{{{filepath}}}",
                                with: "none").replacingOccurrences(of: "{{{faxnumber}}}", with: theFaxNumber)
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


      let body2Datas:[Data] = documentPaths.flatMap{
        let fixedFileName = Bundle.main.resourcePath! + "/" + $0
        let fileContents = readFile(fileName: fixedFileName)
        let mimeType = "image/jpg"
        let image = UIImage(data:fileContents)!
        debugPrint("data: \(image)")
        var info = """
          \(boundary)
          Content-Disposition: form-data; name=\"file\"; filename=\"\($0)\"
          Content-Type: \(mimeType)

          """.CRLFified
        var infoData = info.data(using:.utf8)!

        infoData.append(fileContents)
        infoData.append("\r\n".data(using:.utf8)!)

        return infoData
      }

      let body1Data = body1.CRLFified.data(using:.utf8)!
      let endData = ("\r\n"+boundary+"--").data(using:.utf8)!
      var bodyData = Data()
      bodyData.append(body1Data)
      for d in body2Datas{
        bodyData.append(d)
      }
      bodyData.append(endData)

      req.httpBody = bodyData
      //(body1+body2+"\n"+boundary+"--").replacingOccurrences(of:"\n",with:"\r\n").data(using: .utf8)



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
 */
}


