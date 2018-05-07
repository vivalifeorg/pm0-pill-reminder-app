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
import RNCryptor
import SQLite
import SQLCipher

fileprivate var keychain = Keychain(service:"com.vivalife.app.pm0.prescription-tracking")

public typealias KeychainItem = String

var debugKeychain = false

typealias GlobalTimeslot  = Timeslot



enum LocalStorage{
  enum KeychainKey:String,Codable{
    case userPrescriptions
    case userDoctors
    
    case userInfo

    case userTimeslots
    case systemTimeslots
    
    case userSchedules
    case standardSchedules

    case userDeviceInfo
    case userMedicationLog

    case authentication
  }

  static var MedicationLogStore:FilePersistor<MedicationLogEvent> {
    return FilePersistor(key:.userMedicationLog)
  }

  static var UserInfoStore:KeychainPersistor<PatientInfo>{
    return KeychainPersistor(key:.userInfo)
  }

  static var DeviceStore:KeychainPersistor<String>{
    return KeychainPersistor(key:.userDeviceInfo)
  }

  static var PrescriptionStore:KeychainPersistor<Prescription>{
    return KeychainPersistor(key:.userPrescriptions)
  }


  static var AuthenticationStore:KeychainPersistor<AuthenticationInfo>{
    return KeychainPersistor(key:.authentication)
  }

  static var DoctorStore:KeychainPersistor<DoctorInfo>{
    return KeychainPersistor(key:.userDoctors)
  }

  struct TimeslotStore:Codable{
    static var User:KeychainPersistor<GlobalTimeslot>{
      return KeychainPersistor(key:.userTimeslots)
    }
    static var Standard:KeychainPersistor<GlobalTimeslot>{
      return KeychainPersistor(key:.systemTimeslots)
    }
  }

  struct ScheduleStore:Codable{
    static var User:KeychainPersistor<Schedule>{
      return KeychainPersistor(key:.userSchedules)
    }
    static var Standard:KeychainPersistor<Schedule>{
      return KeychainPersistor(key:.standardSchedules)
    }
  }
}

protocol LocalStorageWrapper{
  associatedtype Wrapped
  associatedtype Wrapper
  static var key:LocalStorage.KeychainKey {get}
  var version:String {get}
}


protocol Persistor{
  associatedtype PersistedType:Codable
  var key:LocalStorage.KeychainKey {get set}
  func blank()
  func load()->[PersistedType]
  func save(_ items:[PersistedType])
}

struct KeychainPersistor<T:Codable>:Persistor{
  typealias PersistedType = T
  var key:LocalStorage.KeychainKey
  func blank(){
    BlankLocal(key: key)
  }
  func load()->[T]{
    return LoadLocal(key: key)
  }

  func loadSingle()->T?{
    return LoadLocal(key: key).first
  }
  func save(_ items:[T]){
    SaveLocal(items, key: key)
  }
}

extension FileManager {
  class func documentsDirectory() -> String {
    var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
    return paths[0]
  }
}

struct FilePassword:Codable{
  let password:String
  let logFiles:[String]
}

/// Stores things to a series of log files
fileprivate var openFilePersistorDBConnection:[String:OpaquePointer?] = [:] //swift static class variables aren't supported on generics
struct FilePersistor<T:Codable>:Persistor{
  typealias PersistedType = T
  var key:LocalStorage.KeychainKey



  func blank(){
    KeychainPersistor<FilePassword>(key: key).blank()
    _ = try? FileManager.default.removeItem(atPath: persistenceFilePath)
  }

  func loadFromDB(datePredicateStr:String) -> String{
    let stmtString = "SELECT relevantDate, jsonEncoded FROM \(FilePersistor<T>.tableName);"
    var statement: OpaquePointer? = nil

    let prepResult = sqlite3_prepare_v2(db, stmtString, -1, &statement, nil)
    guard prepResult == SQLITE_OK else{
      print("SELECT statement could not be prepared")
      return ""
    }
    defer {
      sqlite3_finalize(statement)
    }

    guard  sqlite3_step(statement) == SQLITE_ROW else{
      print("No results")
      return ""
    }

    let dateStr = String(cString:sqlite3_column_text(statement, 0))
    let json = String(cString:sqlite3_column_text(statement, 1))

    return "Date:\(dateStr) JSON:\(json)"
  }

  func load() -> [T] {
    ensureDBIsEncrypted()
    createTableIfNeeded()

    print(loadFromDB(datePredicateStr: "2018-05-07"))
    
    guard let ciphertext = try? Data.init(contentsOf:URL(fileURLWithPath: persistenceFilePath)) else{
      print("missing file: \(persistenceFilePath)")
      return []
    }
    guard let data = try? RNCryptor.decrypt(data: ciphertext, withPassword: storedEncryptionKey()) else{
      print("couldn't decrypt file: \(persistenceFilePath)")
      return []
    }

    return decodeData(data)
  }

  private static func db(filePath:String,encryptionKey:String)->OpaquePointer? {
    if let path = openFilePersistorDBConnection[filePath]{
      return path
    }

    let password: String = encryptionKey
    var db: OpaquePointer? = nil
    var rc:Int32 = sqlite3_open(filePath, &db)
    if (rc != SQLITE_OK) {
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error opening database: \(errmsg)")
      return nil
    }

    rc = sqlite3_key(db, password, Int32(password.utf8CString.count))
    if (rc != SQLITE_OK) {
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error setting key: \(errmsg)")
    }

    openFilePersistorDBConnection[filePath] = db
    return db
  }



  private var db:OpaquePointer!{
    return FilePersistor<T>.db(filePath: persistenceFilePath, encryptionKey: storedEncryptionKey())
  }

  //allow for easier migrations
  private static var versionPrefix:String{
    return "v0_2"
  }

  private static var tableName:String{
    return "Entries"
  }



  private func createTableIfNeeded(){

    //JSON Encoding is silly here but time is short at the moment
    let theTableName = FilePersistor<T>.tableName
    let createTableString = """
    CREATE TABLE \(theTableName)(
    Id INT PRIMARY KEY NOT NULL,
    TEXT relevantDate,
    TEXT jsonEncoded;
    """
    var createTableStatement: OpaquePointer? = nil
    let prepResult = sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil)
    guard  prepResult == SQLITE_OK else{
      print("CREATE TABLE statement could not be prepared.")
      return
    }

    guard sqlite3_step(createTableStatement) == SQLITE_DONE else{
      print("\(key) file persistor not be created. Possibly already exists.")
      return
    }
    defer {
      sqlite3_finalize(createTableStatement)
    }

    print("\(theTableName) Table created")
    sqlite3_finalize(createTableStatement)
  }

  func save(_ items:[T]){
    ensureDBIsEncrypted()
    createTableIfNeeded()

    //We need to load/generate a password for symmetric encryption, and save it
    let password = storedEncryptionKey()
    KeychainPersistor<FilePassword>(key: key).save([FilePassword(password:password,logFiles:[persistenceFilePath])])

    //now, we encode then encrypt the data
    let wrapped = Wrapper<T>(wrapped:items,key:key)
    guard let encoded = try? JSONEncoder().encode(wrapped) else {
      return
    }

    if shouldExportToYamlForTesting {
      printYamlAndHeader(wrapped, key: key, addAssociated:true)
    }

    


    /*
    let ciphertextData = RNCryptor.encrypt(data:encoded,withPassword:password)

    do{
      try ciphertextData.write(to:URL(fileURLWithPath: persistenceFilePath))
    }catch{
      print("Failed to write file")
    }
     */
  }

  //////

  //todo make a way to autopage to a new log file when appropriate
  private func generateKey()->String{
    debugPrint("Generating Key/Password for checks because we don't have one")
    return RNCryptor.randomData(ofLength: 12).base64EncodedString()
  }

  private func storedEncryptionKey()->String{
    let encryptionKey = KeychainPersistor<FilePassword>(key: key).load().first?.password ?? generateKey()
    return encryptionKey
  }

  static private func filepath(`for` key:LocalStorage.KeychainKey, index:Int = 0)->String{
    let currentLogIndex = String(0)
    let paddedIndex = currentLogIndex.padding(toLength: 8, withPad: "0", startingAt: 0)
    let prefix = "FilePersistorData-"
    return FileManager.documentsDirectory() + "/" + prefix + key.rawValue + "_" + paddedIndex + ".db"
  }

  private var persistenceFilePath:String{
    return FilePersistor<T>.filepath(for:key, index:0)
  }

  private func ensureDBIsEncrypted(){
    let password: String = storedEncryptionKey()
    var db: OpaquePointer? = nil
    var rc:Int32 = sqlite3_open(persistenceFilePath, &db)
    if (rc != SQLITE_OK) {
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error opening database: \(errmsg)")
      return
    }

    rc = sqlite3_key(db, password, Int32(password.utf8CString.count))
    if (rc != SQLITE_OK) {
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error setting key: \(errmsg)")
    }

    var stmt: OpaquePointer? = nil
    rc = sqlite3_prepare(db, "PRAGMA cipher_version;", -1, &stmt, nil)
    if (rc != SQLITE_OK) {
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error preparing SQL: \(errmsg)")
    }
    rc = sqlite3_step(stmt)
    if (rc == SQLITE_ROW) {
      NSLog("SQLCipher: cipher_version: %s", sqlite3_column_text(stmt, 0))
    } else {
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error retrieiving cipher_version: \(errmsg)")
    }
    sqlite3_finalize(stmt)
    sqlite3_close(db)
  }
}

private func BlankLocal(key:LocalStorage.KeychainKey){
  let key = key.rawValue as String
  debugPrint("BLANKING \(key)")
  keychain[string: key] = nil
}

private func decodeData<T:Codable>(_ dataT:Data)->[T]{

  guard let items = try? JSONDecoder().decode(Wrapper<T>.self, from: dataT) else{
    print("Could not decode data in \(T.self)")
    return []
  }

  return items.wrapped
}

private func LoadLocal<T:Codable>(key:LocalStorage.KeychainKey)->[T]{
  guard let stringT = keychain[string: key.rawValue] else {
    return []
  }

  guard let dataT = stringT.data(using: .utf8) else {
    return []
  }

  return decodeData(dataT)
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
let shouldExportToYamlForTesting = false

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

fileprivate func yamlize<T:Codable>(_ toEncode:T, key:LocalStorage.KeychainKey)->String{
  return (try? yamlEncoder.encode(toEncode)) ?? "<<Encoding Error>>"
}

fileprivate func printYamlAndHeader<T:Codable>(_ wrapped:T, key:LocalStorage.KeychainKey, addAssociated:Bool = false){
  print("# ==== \(addAssociated ? "Associated " : "")Storage Key: \(key.rawValue) ====")
  print("# ==== Exporting OS Name: \(operatingSystemName) ====")
  print("# ==== Exporting OS Version: \(operatingSystemVersion) ====")
  print("# ==== Exporting App Version: \(Bundle.main.compositeVersionNumber) ====")
  print("# ==== Export Date: \(Date()) ====")
  print("# ==== \(key.rawValue) BEGIN ====")
  print(yamlize(wrapped, key:key))
  print("# ==== \(key.rawValue) END ====")
}

private func SaveLocal<T:Codable>(_ items:[T], key:LocalStorage.KeychainKey){
  let wrapped = Wrapper<T>(wrapped:items,key:key)
  guard let encoded = try? JSONEncoder().encode(wrapped) else {
    return
  }

  if shouldExportToYamlForTesting {
    printYamlAndHeader(wrapped, key: key)
  }

  keychain[string: key.rawValue] = String(data:encoded,encoding:.utf8)
}







