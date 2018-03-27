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
    case userDoctors
  }

  static var prescriptions:Persistor<Prescription>{
    return Persistor(key:.userPrescriptions)
  }
  static var doctors:Persistor<DoctorInfo>{
    return Persistor(key:.userDoctors)
  }
}

protocol LocalStorageWrapper{
  associatedtype Wrapped
  associatedtype Wrapper
  static var key:LocalStorage.KeychainKey {get}
  var version:String {get}
}

struct Persistor<T:Codable>{
  var key:LocalStorage.KeychainKey
  func blank(){
    BlankLocal(key: key)
  }
  func load()->[T]{
    return LoadLocal(key: key)
  }
  func save(_ items:[T]){
    SaveLocal(items, key: key)
  }
}

private func BlankLocal(key:LocalStorage.KeychainKey){
  let key = key.rawValue as String
  keychain[string: key] = nil
}

private func LoadLocal<T:Codable>(key:LocalStorage.KeychainKey)->[T]{
  guard let stringT = keychain[string: key.rawValue] else {
    return []
  }

  guard let dataT = stringT.data(using: .utf8) else {
    return []
  }

  guard let items = try? JSONDecoder().decode(Wrapper<T>.self, from: dataT) else{
    return []
  }

  return items.wrapped
}


struct Wrapper<T:Codable>:Codable{
  enum WrapperVersions:String,Codable{
    case v0_1_unversioned
  }

  let wrapped:[T]
  var version:String{
    return WrapperVersions.v0_1_unversioned.rawValue
  }
}

private func SaveLocal<T:Codable>(_ items:[T], key:LocalStorage.KeychainKey){
  let wrapped = Wrapper<T>(wrapped:items)
  guard let encoded = try? JSONEncoder().encode(wrapped) else {
    return
  }

  keychain[string: key.rawValue] = String(data:encoded,encoding:.utf8)
}







