//
//  Authentication.swift
//  pm0
//
//  Created by Michael Langford on 5/3/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import LocalAuthentication


/// Allows us to ensure they are using at least a passcode
///
/// - Returns: true if they are
func isUserUsingStrongEnoughAuthentication()->Bool{
  let context = LAContext()
  return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error:nil)
}

/// Rolls up the changing apple responses into app specific ones
///
/// - succeeded: We should let them in
/// - failed: they tried, and failed, log it probably
/// - canceled: they started, then chose to stop
/// - unknown: we aren't sure what's going on
enum AuthenticationOutcome:String{
  case succeeded
  case failed
  case canceled
  case unknown
}

//strong refrerence to auth context to not lose it during run
fileprivate let authenicationContext = LAContext()


/// Figures out what the authentication error means
///
/// - Parameters:
///   - error: The error, if one was returned
///   - completion: what to report to the main client code, gets rid of most of the complexity in here
func decodeAuthenticationError(_ error:Error?, completion:@escaping (AuthenticationOutcome)->()){
  print("auth failed")
  vlAuthState = .notAuthenticted
  guard let error = error as? LAError else{
    completion(.unknown)
    return
  }

  switch error.code{
  case LAError.authenticationFailed:
    completion(.failed)
    return
  default:
    completion(.canceled)
    return
  }
}

/**
 Checks to see if the owner of the phone has it in their posession
 */
/// Can they prove they own the phone
///
/// - Parameter completion: Shows success if they do, otherwise, various types of non-authentication
func authenticateUser(completion:@escaping (AuthenticationOutcome)->()) {
  vlAuthState = .authenticating

  let replyHandler:(Bool, Error?) -> Void = { success, error in
    guard success else{
      decodeAuthenticationError(error,completion:completion)
      return
    }

    print("Auth worked")
    vlAuthState = .authenticated
    completion(.succeeded)
  }

  let loginScreenText = "Sign into your device to proceed.\n\nThis uses TouchID, FaceID or your normal \(UIDevice.current.localizedModel) passcode"
  authenicationContext.evaluatePolicy(
    LAPolicy.deviceOwnerAuthentication,
    localizedReason: loginScreenText,
    reply: replyHandler
  )

}


/// App encoding of different ways the user is allowed to setup authentication to their data
///
/// - biometricOrPasscodeOSLock: The only allowed one right now, iOS passcode lock or biometrics
enum UserAuthenticationMode:String,Codable{
  case biometricOrPasscodeOSLock
}


/// Information about login attemtps, history, and how the user wants to login
struct AuthenticationInfo:Codable{
  var firstRun:Bool = true //be careful to not break login with this
  var numberOfTimesLoggedIn:Int = 0
  var numberOfFailedLoginAttempts:Int = 0
  var lastLogin:Date? = nil
  var authenticationMode:UserAuthenticationMode = .biometricOrPasscodeOSLock
}

/// Is the user currently signed in
///
/// - authenticated: Yes
/// - notAuthenticted: No
/// - authenticating: Working on it
enum VLAuthenticationState{
  case authenticated
  case notAuthenticted
  case authenticating
}

/// Signals we locked the device, etc
class VLNeedsAuthAgainNotification:NSNotification{
  static var name:NSNotification.Name{
    return  NSNotification.Name(rawValue: "VLNeedsAuthAgainNotification")
  }
}

/// The user tried to auth, then failed
class VLFailedAuthNotification:NSNotification{
  static var name:NSNotification.Name{
    return  NSNotification.Name(rawValue: "VLFailedAuthNotification")
  }
}

/// The user tried to auth, then succeded
class VLSuccededAuthNotification:NSNotification{
  static var name:NSNotification.Name{
    return  NSNotification.Name(rawValue: "VLSuccededAuthNotification")
  }
}

/// Allows us to skip notifications for startup code, etc
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
