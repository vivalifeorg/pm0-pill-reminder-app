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
  //poboyAuthState = .authenticating
  let context = LAContext()
  context.evaluatePolicy( LAPolicy.deviceOwnerAuthentication,
                          localizedReason: "Sign into your device to proceed") { success, error in
                            if success {
                              print("Auth worked")
                              completion(true)
                            }else{
                              print("auth failed")
                              completion(false)
                            }
  }
}
