//
//  Authentication.swift
//  pm0
//
//  Created by Michael Langford on 5/3/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import LocalAuthentication

/**
 we require they use at least a passcode, if not biometrics
 */
func isUserUsingStrongEnoughAuthentication()->Bool{
  let context = LAContext()
  return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error:nil)
}

/**
 Checks to see if the owner of the phone has it in their posession
 */
func authenticateUser(completion:@escaping (Bool)->()) {
  vlAuthState = .authenticating
  let context = LAContext()
  context.evaluatePolicy( LAPolicy.deviceOwnerAuthentication,
                          localizedReason: "Sign into your device to proceed.\n\nThis uses your normal iOS passcode, TouchID, or FaceID.") { success, error in
                            if success {
                              print("Auth worked")
                              vlAuthState = .authenticated
                              completion(true)
                            }else{
                              print("auth failed")
                              vlAuthState = .notAuthenticted
                              completion(false)
                            }
  }
}


enum UserAuthenticationMode:String,Codable{
  case biometricOrPasscodeOSLock
}

struct AuthenticationInfo:Codable{
  var firstRun:Bool = true //be careful to not break login with this
  var numberOfTimesLoggedIn:Int = 0
  var numberOfFailedLoginAttempts:Int = 0
  var lastLogin:Date? = nil
  var authenticationMode:UserAuthenticationMode = .biometricOrPasscodeOSLock
}

enum VLAuthenticationState{
  case authenticated
  case notAuthenticted
  case authenticating
}

class VLNeedsAuthAgainNotification:NSNotification{
  static var name:NSNotification.Name{
    return  NSNotification.Name(rawValue: "VLNeedsAuthAgainNotification")
  }
}

class VLFailedAuthNotification:NSNotification{
  static var name:NSNotification.Name{
    return  NSNotification.Name(rawValue: "VLFailedAuthNotification")
  }
}

class VLSuccededAuthNotification:NSNotification{
  static var name:NSNotification.Name{
    return  NSNotification.Name(rawValue: "VLSuccededAuthNotification")
  }
}

var vlAuthState:VLAuthenticationState = .notAuthenticted {
  willSet{

    let old = vlAuthState
    let toNew = newValue

    switch (old,toNew) {
    case (.authenticating,.notAuthenticted):
      NotificationCenter.default.post(name: VLFailedAuthNotification.name, object: nil)

    case (.authenticating,.authenticated):
      NotificationCenter.default.post(name: VLSuccededAuthNotification.name, object: nil)

    default:
      break
    }
  }
}
