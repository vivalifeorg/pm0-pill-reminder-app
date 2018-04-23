//
//  Fax.swift
//  pm0
//
//  Created by Michael Langford on 3/14/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation
import PDFKit
typealias DocumentRef = URL


struct DocumentDestination{
  var name:String
  var value:String
}

extension PDFDocument{
  var pages:[PDFPage]{
    var xs:[PDFPage] = []
    for i in 0..<pageCount{
      guard let thePage = page(at: i) else{
        continue
      }
      xs.append(thePage)
    }
    return xs
  }
}

extension Array where Element == DocumentRef{
  var singleDocument:PDFDocument {
    let allPages = flatMap{PDFDocument(url: $0)}.map{$0.pages}.flatMap{$0}
    let doc = PDFDocument()
    allPages.forEach { (page) in
      doc.insert(page, at: doc.pageCount)
    }
    return doc
  }

  var singleDocumentWithMargin:PDFDocument {
    let allPages = flatMap{PDFDocument(url: $0)}.map{$0.pages}.flatMap{$0}
    let doc = PDFDocument()
    allPages.forEach { (page) in
      if let mediaBox = page.pageRef?.getBoxRect(.mediaBox){
        let widthToHeightOfLetterSizedPaper:CGFloat = (8.5/11.0)
        let isOverlyBroad = mediaBox.width / mediaBox.height > widthToHeightOfLetterSizedPaper
        let cropBox:CGRect

        if isOverlyBroad {
          //make it have a taller crop box
          let totalHeight:CGFloat = mediaBox.width / widthToHeightOfLetterSizedPaper
          let addedHeight:CGFloat = totalHeight - mediaBox.height
          cropBox = CGRect(x: mediaBox.minX ,
                               y: mediaBox.minY - (CGFloat(0.5) * addedHeight) ,
                               width: mediaBox.width,
                               height: mediaBox.height + ( addedHeight))
        }else{
          //make it have a wider crop box
          let totalWidth:CGFloat = mediaBox.height * widthToHeightOfLetterSizedPaper
          let addedWidth:CGFloat = totalWidth - mediaBox.width
          cropBox = CGRect(x: mediaBox.minX - (CGFloat(0.5) * addedWidth) ,
                               y: mediaBox.minY ,
                               width: mediaBox.width +  addedWidth,
                               height: mediaBox.height )
        }
        dump((cropBox))
       page.setBounds(cropBox, for: .cropBox)
      }
       doc.insert(page, at: doc.pageCount)
    }
    return doc
  }
}

func sendFax(toNumber:String, documentPaths:[DocumentRef],completion:@escaping (Bool,String)->()){
  phaxioObjcFaxService.sendFaxUsingService(toNumber:toNumber,
                                           documentPaths:documentPaths,
                                           completion:completion)
}


protocol FaxServiceProvider{
  func sendFax(authentication:FaxService.Credentials,
               otherInfo:FaxService.OtherSenderInfo,
               toNumber:String,
               documentPaths:[DocumentRef],
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
                                  documentPaths:[DocumentRef],
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

  func sendFaxUsingService(toNumber:String, documentPaths:[DocumentRef],completion:@escaping (Bool,String)->()){
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

func readFile(fileURL: URL) -> Data{
  return try! NSData(contentsOf: fileURL) as Data
}

func readFile(fileName: String) -> Data{
  return try! NSData.init(contentsOfFile:fileName, options:[]) as Data
}




