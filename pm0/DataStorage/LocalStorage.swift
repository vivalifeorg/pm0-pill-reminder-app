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

enum LocalStorage{
  enum KeychainKey:String{
    case userPrescriptions
  }

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

