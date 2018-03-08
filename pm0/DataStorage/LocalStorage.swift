//
//  LocalStorage.swift
//  pm0
//
//  Created by Michael Langford on 3/8/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

//
//  Keychain.swift
//  DoseBleedTracking
//
//  Created by Michael Langford on 9/29/17.
//  Copyright © 2017 Michael Langford. All rights reserved.
//

import Foundation
import KeychainAccess



fileprivate var keychain = Keychain(service:"com.vivalife.app.pm0.prescription-tracking")

public typealias KeychainItem = String

var debugKeychain = false


enum KeychainKey:String{
  case userPrescriptions
}

enum LocalStorage{


  func SaveKeychainItem(_ item:KeychainItem, forKey key:KeychainKey) {

    if debugKeychain {debugPrint("Saving \(item) to keychain for key \(key)")}
    keychain[string: key.rawValue] = item
  }

  func ClearKeychainItem(forKey key:KeychainKey) {
    if debugKeychain {
      debugPrint("Clearing keychain for key \(key)")
    }

    keychain[string: key.rawValue] = nil
  }

  func IsKeychainItemPresent(forKey key:KeychainKey) -> Bool {
    //debugPrint("Checking keychain for key \(key)")
    return keychain[string: key.rawValue] != nil
  }

  func LoadKeychainItem(forKey key:KeychainKey) -> KeychainItem {
    if debugKeychain {debugPrint("Loading item from keychain for key \(key)")}
    return keychain[string: key.rawValue] ?? ""
  }

}

extension LocalStorage{

  static func BlankPrescriptions(){
    let key = KeychainKey.userPrescriptions.rawValue as String
    keychain[string: key] = nil
  }

  static func LoadPrescriptions()->[Prescription]{
    let key = KeychainKey.userPrescriptions.rawValue as String
    guard let stringRx = keychain[string: key] else {
      return []
    }

    guard let dataRx = stringRx.data(using: .utf8) else {
      return []
    }

    let rxs = try? JSONDecoder().decode([Prescription].self, from: dataRx)
    return rxs ?? []
  }

  static func SavePrescriptions(_ prescriptions:[Prescription]){

    guard let encodedRx = try? JSONEncoder().encode(prescriptions) else {
      return
    }

    let key = KeychainKey.userPrescriptions.rawValue as String
    keychain[string: key] = String(data:encodedRx,encoding:.utf8)
  }
}

