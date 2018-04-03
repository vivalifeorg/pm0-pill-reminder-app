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
import Yams


fileprivate var keychain = Keychain(service:"com.vivalife.app.pm0.prescription-tracking")

public typealias KeychainItem = String

var debugKeychain = false

typealias GlobalTimeslot  = Timeslot

enum LocalStorage{
  enum KeychainKey:String,Codable{
    case userPrescriptions
    case userDoctors
    case userTimeslots
    case systemTimeslots
    case userSchedules
    case systemSchedules
  }

  static var PrescriptionStore:Persistor<Prescription>{
    return Persistor(key:.userPrescriptions)
  }

  static var DoctorStore:Persistor<DoctorInfo>{
    return Persistor(key:.userDoctors)
  }

  struct TimeslotStore:Codable{
    static var User:Persistor<GlobalTimeslot>{
      return Persistor(key:.userTimeslots)
    }
    static var System:Persistor<GlobalTimeslot>{
      return Persistor(key:.systemTimeslots)
    }
  }

  struct ScheduleStore:Codable{
    static var User:Persistor<Schedule>{
      return Persistor(key:.userSchedules)
    }
    static var System:Persistor<Schedule>{
      return Persistor(key:.systemSchedules)
    }
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
  let version:String = WrapperVersions.v0_1_unversioned.rawValue
  let key:LocalStorage.KeychainKey
}


let yamlEncoder = YAMLEncoder()
let shouldExportToYamlForTesting = true

let operatingSystemName = UIDevice.current.systemName
let operatingSystemVersion = UIDevice.current.systemVersion

extension Bundle {
  var releaseVersionNumber: String! {
    return infoDictionary?["CFBundleShortVersionString"] as? String
  }
  var buildVersionNumber: String! {
    return infoDictionary?["CFBundleVersion"] as? String
  }
  var compositeVersionNumber: String{
    return "\(releaseVersionNumber!) (\(buildVersionNumber!))"
  }
}

func yamlize<T:Codable>(_ toEncode:T, key:LocalStorage.KeychainKey)->String!{
  return try? yamlEncoder.encode(toEncode)
}

private func SaveLocal<T:Codable>(_ items:[T], key:LocalStorage.KeychainKey){
  let wrapped = Wrapper<T>(wrapped:items,key:key)
  guard let encoded = try? JSONEncoder().encode(wrapped) else {
    return
  }

  if shouldExportToYamlForTesting {
    print("# ==== Storage Key: \(key.rawValue) ====")
    print("# ==== Exporting OS Name: \(operatingSystemName) ====")
    print("# ==== Exporting OS Version: \(operatingSystemVersion) ====")
    print("# ==== Exporting App Version: \(Bundle.main.compositeVersionNumber) ====")
    print("# ==== Export Date: \(Date()) ====")
    print("# ==== \(key.rawValue) BEGIN ====")
    print(yamlize(wrapped, key:key))
    print("# ==== \(key.rawValue) END ====")
  }

  keychain[string: key.rawValue] = String(data:encoded,encoding:.utf8)
}







