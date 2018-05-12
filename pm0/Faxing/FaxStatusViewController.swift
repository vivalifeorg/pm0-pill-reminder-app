//
//  FaxStatusViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/26/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class FaxStatusViewController:UIViewController{

  @IBOutlet weak var  vivaLogo:UIImageView!
  @IBOutlet weak var  medLogo:UIImageView!
  @IBOutlet weak var  faxIcon:UIImageView!
  @IBOutlet weak var  faxLeadingSpace:NSLayoutConstraint!
  @IBOutlet weak var  cancelButton:UIButton!
  @IBOutlet weak var  statusLabel:UILabel!

  var isAnimating = true

  func resetAnimation(){
    guard isAnimating else{
      return
    }
    faxLeadingSpace.constant = vivaLogo.frame.origin.x
  }


  func animateStep(){
    faxLeadingSpace.constant = medLogo.frame.origin.x
    self.view.layoutIfNeeded()
  }

  func updateStatus(message:String, cancelButtonEnabled:Bool){
    statusLabel.text = message
    cancelButton.isEnabled = cancelButtonEnabled
    if cancelButtonEnabled == false{
      stopAnimations()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.view.backgroundColor = UIColor(patternImage:  Asset.FaxAnim.faxStatusBackground.image)

    resetAnimation()
    UIView.animate(withDuration: 1.2,
                   delay: 0.5,
                   options: [.repeat],
                   animations: { self.animateStep()},
                   completion: { _ in self.resetAnimation()})

  }

  func stopAnimations(){
    isAnimating = false
    self.view.layer.removeAllAnimations()
  }
  override func viewWillDisappear(_ animated: Bool) {
    stopAnimations()
  }
  override func viewWillAppear(_ animated: Bool) {
    self.view.backgroundColor = UIColor(patternImage:  Asset.FaxAnim.faxStatusBackground.image)
  }
  override func viewDidLoad() {

  }
}
