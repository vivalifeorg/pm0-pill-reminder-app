//
//  PrescriptionLineEntry.swift
//  pm0
//
//  Created by Michael Langford on 2/28/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SearchTextField

///A single entry area for information on a prescription
class PrescriptionLineEntry: UIView{

  @IBOutlet var contentView:UIView!
  @IBOutlet var addFromContactsButton:UIButton!
  @IBOutlet var showHelpButton:UIButton!
  @IBOutlet var titleLabel:UILabel!
  @IBOutlet var searchTextField:SearchTextField!


  @IBInspectable
  public var title: String = "Title TK" {
    didSet {
      titleLabel.text = title
    }
  }

  @IBInspectable
  public var placeholder: String = "e.g. TK" {
    didSet {
      searchTextField.placeholder = placeholder
    }
  }

  @IBInspectable
  public var isAddFromContactsButtonHidden: Bool = false {
    didSet {
      addFromContactsButton.isHidden =  isAddFromContactsButtonHidden
    }
  }

  /// Init for code
  override init(frame: CGRect) { //code
    super.init(frame: frame)
    commonInit()
  }

  /// Init for InterfaceBuilder
  required init?(coder aDecoder: NSCoder) { //IB
    super.init(coder:aDecoder)
    commonInit(isFromIB:true)
  }

  /// Join all init here
  private func commonInit(isFromIB:Bool = false){
    let loaded = Bundle.main.loadNibNamed("PrescriptionLineEntry", owner: self, options: nil)
    dump(loaded)
    addSubview(contentView)
    setupConstraints()

    //Calls the didset to use the inital values specified in code
    placeholder = {placeholder}()
    isAddFromContactsButtonHidden = {isAddFromContactsButtonHidden}()
    title = {title}()
  }

  /// Autolayout setup
  private func setupConstraints(){
    translatesAutoresizingMaskIntoConstraints = false
    let views = ["PrescriptionLineEntry":contentView!]
    let metrics = ["FixedHeight":98.0]
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[PrescriptionLineEntry]|",
        options: [],
        metrics: metrics,
        views: views
      )
    )
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[PrescriptionLineEntry(FixedHeight)]|",
        options: [],
        metrics: metrics,
        views: views
      )
    )
  }

}
