//
//  FaxObjcLib.swift
//  pm0
//
//  Created by Michael Langford on 3/20/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation
import PhaxioiOS

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


let phaxioObjcFaxService = FaxService(provider: PhaxioObjcFaxProvider())
class PhaxioObjcFaxProvider:FaxServiceProvider{

  func sendFax(authentication:FaxService.Credentials,
               otherInfo:FaxService.OtherSenderInfo,
               toNumber:String,
               documentPaths:[DocumentRef],
               completion:@escaping (Bool,String)->()){

    PhaxioAPI.setAPIKey(authentication.key, andSecret: authentication.secret)
    let fax = Fax()!
    fax.delegate = apiDelegate
    fax.to_phone_numbers = [toNumber]
    fax.files = documentPaths.map{
      let shortFilename = String($0.absoluteString.split(separator: "/").last!)
      let mimeType = mimeTypeName(shortFilename)
      let data = readFile(fileName: $0.path)
      return FaxFile(data:data, name:shortFilename, mimeTypeName:mimeType)
    }
    self.completion = completion
    fax.send()
  }

  let apiDelegate: PhaxioObjcApiDelegate
  init(){
    apiDelegate = PhaxioObjcApiDelegate()
    apiDelegate.callbackDelegate = doneSending
  }

  var completion:((Bool,String)->())? = nil
  func doneSending(success:Bool,json:[AnyHashable : Any]) {
    completion!(success, json["message"] as! String)
  }


  @objc class PhaxioObjcApiDelegate:NSObject,FaxDelegate{
    func sentFax(_ success:Bool, andResponse json:[AnyHashable : Any]){
      print("Success:\(success) responsse\(json)")
      callbackDelegate(success, json)
    }

    var callbackDelegate:((Bool,[AnyHashable : Any])->())! = nil
  }
}
