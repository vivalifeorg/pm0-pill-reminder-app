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

  static let MedicationLogStore:FilePersistor<MedicationLogEvent> = FilePersistor(key:.userMedicationLog)


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
struct FetchableQueryParams:Hashable{
  let dateString:String
  let key:LocalStorage.KeychainKey
}
extension FetchableQueryParams{
  init(_ pkey:LocalStorage.KeychainKey, _ pdateString:String ){
    key = pkey
    dateString = pdateString
  }
}

///changing this only works with a completely new database
let usesEncryptedDatabase = true

///used to make queries blazingly fast by reuse
fileprivate var filePersistorCachedLoadStatements:[FetchableQueryParams:OpaquePointer?] = [:]
fileprivate var filePersistorCachedSaveStatements:[FetchableQueryParams:OpaquePointer?] = [:]

fileprivate let dateNotSpecified = "NOT_SPECIFIED"

struct FilePersistor<T:Codable>:Persistor{
  typealias PersistedType = T
  var key:LocalStorage.KeychainKey

  func blank(){
    KeychainPersistor<FilePassword>(key: key).blank()
    _ = try? FileManager.default.removeItem(atPath: persistenceFilePath)
  }

  ///should not be used for this class, use date specified or loadLastDays
  func load() -> [T] {
    return load(relevantDate:dateNotSpecified)
  }

  private let daySeconds:Double =  24 * 60 * 60

  ///should be used for things like medlog that need many days of stuff
  func loadLastDays(_ numberOfDays:Int) -> [String:[T]] {
    var dayEvents = [String:[T]]()
    for n in 0..<numberOfDays{
      let today = Date()
      let thatDay = today.addingTimeInterval((-daySeconds) * Double(n) )
      dayEvents[thatDay.relevantDateString] = load(relevantDate:thatDay.relevantDateString)
    }
    return dayEvents
  }

  ///should be primary load mechanism for medlog single days
  func load(relevantDate:String) -> [T] {
    ensureDBIsEncrypted()
    createTableIfNeeded()

    let dbItems = loadFromDB(datePredicateStr: relevantDate)
    let dataItems:[Data] = dbItems.map{ dbItem in
      guard let dataT = dbItem.data(using: .utf8) else {
        fatalError()
      }
      return dataT
    }

    let items:[T] = dataItems.map{ dataT in
      guard let item = (try? JSONDecoder().decode(Wrapper<T>.self, from: dataT))?.wrapped.first else{
        print("Could not decode data in \(T.self)")
        fatalError()
      }
      return item
    }
    return items
  }

  ///should be used; Adds events to the medlog
  func append(_ items:[T], relevantDate:String = dateNotSpecified){
    save(items, relevantDate:relevantDate)
  }

  ///Saves the given items, generally not intended for use
  func save(_ items:[T]){
    save(items,relevantDate:dateNotSpecified)
  }

  ///Saves the given items  for the date specified, generally not intended for use
  func save(_ items:[T], relevantDate:String = dateNotSpecified){

    //now, we encode the data a little awkwardly
    let encodedItems:[Data] = items.map{ item in
      let wrappedItem = Wrapper<T>(wrapped:[item],key:key)
      guard let encoded = try? JSONEncoder().encode(wrappedItem) else {
        fatalError("Encoding is broken for these")
      }
      return encoded
    }

    if shouldExportToYamlForTesting {
      encodedItems.forEach { wrapped in
        printYamlAndHeader(wrapped, key: key, addAssociated:true)
      }
    }

    //
    //encrypt and store the data
    //
    let encodedStrings = encodedItems.map{
      String(data:$0,encoding:.utf8)!
    }

    //We need to load/generate a password for symmetric encryption, and save it
    let password = storedEncryptionKey()
    KeychainPersistor<FilePassword>(key: key).save([FilePassword(password:password,logFiles:[persistenceFilePath])])
    ensureDBIsEncrypted()
    createTableIfNeeded()
    writeToDB(data: encodedStrings, datePredicateStr: relevantDate)
  }


  private func loadFromDB(datePredicateStr:String) -> [String]{
    var statement:OpaquePointer?
    if let cached = filePersistorCachedLoadStatements[FetchableQueryParams(key,datePredicateStr)] {
      statement = cached
    }else{
      let stmtString = "SELECT relevantDate, jsonEncoded FROM \(FilePersistor<T>.tableName) where relevantDate=?;"
      let prepResult = sqlite3_prepare_v2(db, stmtString, -1, &statement, nil)
      guard prepResult == SQLITE_OK else{
        print("SELECT statement could not be prepared ERROR \(prepResult) \(String(cString: sqlite3_errmsg(db)))")
        return []
      }
      filePersistorCachedLoadStatements[FetchableQueryParams(key,datePredicateStr)] = statement
    }

    sqlite3_bind_text(statement, Int32(1), datePredicateStr, -1, SQLITE_TRANSIENT)
    var items:[String] = []
    while (sqlite3_step(statement) == SQLITE_ROW) {
      _ = String(cString:sqlite3_column_text(statement, 0))
      let json = String(cString:sqlite3_column_text(statement, 1))
      items.append(json)
    }
    sqlite3_reset(statement)
    return items
  }

  internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
  internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  private func writeToDB(data:[String], datePredicateStr:String){
    var statement:OpaquePointer?
    if let cached = filePersistorCachedSaveStatements[FetchableQueryParams(key,datePredicateStr)] {
      statement = cached
    }else{
      /*
       INSERT INTO artists (name) VALUES ('Bud Powell');
      */
      let stmtString = "insert into entries (relevantDate, encodingVersion, jsonEncoded) VALUES (?,?,?);"
      let prepResult = sqlite3_prepare_v2(db, stmtString, -1, &statement, nil)
      guard prepResult == SQLITE_OK else{
        print("insert statement could not be prepared ERROR \(prepResult) \(String(cString: sqlite3_errmsg(db)))")
        return
      }
      filePersistorCachedSaveStatements[FetchableQueryParams(key,datePredicateStr)] = statement
    }

    ///Be careful with memory management and bind calls: SQL lite is in C memory management mode
    for (_,item) in data.enumerated() {
      let bind1Result = sqlite3_bind_text(statement, Int32(1), datePredicateStr, -1, SQLITE_TRANSIENT)
      guard bind1Result == SQLITE_OK else{
        print("Error making bind \(bind1Result):\(String(cString: sqlite3_errmsg(db)))")
        return
      }
      let bind2Result = sqlite3_bind_text(statement, Int32(2), FilePersistor<T>.currentEncodingVersion, -1, SQLITE_TRANSIENT)
      guard bind2Result == SQLITE_OK else{
        print("Error making bind \(bind2Result):\(String(cString: sqlite3_errmsg(db)))")
        return
      }
      let bind3Result = sqlite3_bind_text(statement, Int32(3), item, -1, SQLITE_TRANSIENT)
      guard bind3Result == SQLITE_OK else{
        print("Error making bind \(bind3Result):\(String(cString: sqlite3_errmsg(db)))")
        return
      }

      let stepResult = sqlite3_step(statement)
      guard stepResult == SQLITE_DONE else{
        print("ERROR: \(stepResult) \(String(cString: sqlite3_errmsg(db)))")
        return
      }
      sqlite3_reset(statement)
    }

  }

  private static func db(filePath:String,encryptionKey:String)->OpaquePointer? {
    if let path = openFilePersistorDBConnection[filePath]{
      return path
    }

    var db: OpaquePointer? = nil
    let openResult:Int32 = sqlite3_open(filePath, &db)
    guard openResult == SQLITE_OK  else{
      let errmsg = String(cString: sqlite3_errmsg(db))
      NSLog("SQLCipher: Error opening database: \(errmsg) at path \(filePath)")
      return nil
    }

    if usesEncryptedDatabase{
      let password: String = encryptionKey
      let keyResult = sqlite3_key(db, password, Int32(password.utf8CString.count))
      guard keyResult == SQLITE_OK else {
        let errmsg = String(cString: sqlite3_errmsg(db))
        NSLog("SQLCipher: Error setting key: \(errmsg) at path \(filePath)")
        return nil
      }
    }

    openFilePersistorDBConnection[filePath] = db
    return db
  }

  //this is the db that is there, app may crash in low disk space situations
  private var db:OpaquePointer!{
    return FilePersistor<T>.db(filePath: persistenceFilePath, encryptionKey: storedEncryptionKey())
  }

  //allow for easier migrations
  private static var currentEncodingVersion:String{
    return Wrapper<T>.WrapperVersions.v1_0_180508_2008.rawValue
  }

  //version this eventually?
  private static var tableName:String{
    return "Entries"
  }


  private func createTableIfNeeded(){

    //JSON Encoding is silly here but time is short at the moment
    let theTableName = FilePersistor<T>.tableName
    let createTableString = """
    CREATE TABLE \(theTableName)(
    Id INTEGER PRIMARY KEY NOT NULL,
    relevantDate TEXT,
    encodingVersion TEXT,
    jsonEncoded TEXT);
    """
    var createTableStatement: OpaquePointer? = nil
    let prepResult = sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil)
    guard  prepResult == SQLITE_OK else{
      let errorMsg = String(cString: sqlite3_errmsg(db))
      if errorMsg != "table Entries already exists"{
        print("CREATE TABLE statement could not be prepared. ERROR \(prepResult), \(sqlite3_extended_errcode(db)), \(String(cString: sqlite3_errmsg(db))) reguarding db at \(persistenceFilePath)")
      }
      return
    }

    let stepResult = sqlite3_step(createTableStatement)
    guard stepResult == SQLITE_DONE else{
      print("\(key) file persistor not be created. Possibly already exists. ERROR \(stepResult) \(String(cString: sqlite3_errmsg(db)))")
      return
    }
    defer {
      sqlite3_finalize(createTableStatement)
    }

    print("\(theTableName) Table created")
  }

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
    let encStr = usesEncryptedDatabase ? "encrypted-": ""
    let prefix = "FilePersistorData-\(encStr)"
    return FileManager.documentsDirectory() + "/" + prefix + key.rawValue + "_" + paddedIndex + ".db"
  }

  private var persistenceFilePath:String{
    return FilePersistor<T>.filepath(for:key, index:0)
  }

  private func ensureDBIsEncrypted(){
    guard usesEncryptedDatabase else {//should only be disabled on debug builds
      print("ENCRYPTION NOT ENABLED")
      return
    }

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
    case v0_2_unversioned
    case v0_2_180507_2110
    case v1_0_180508_2008
  }

  let wrapped:[T]
  let version:String = WrapperVersions.v1_0_180508_2008.rawValue
  let key:LocalStorage.KeychainKey
}


let yamlEncoder = YAMLEncoder()
let shouldExportToYamlForTesting = false //this is primarily to increase readability, and to show what the JSON looks like for use when writing webservices/android. It is comparatively quite slow, and the the print statements it makes are even slower, so don't leave it on when released. Yaml output is *excellent* though for use in testing, and you can re-encode it back to json easily using the same library. 

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







