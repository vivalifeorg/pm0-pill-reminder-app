//
//  PrescriptionLineEntry.swift
//  pm0
//
//  Created by Michael Langford on 2/28/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SearchTextField

@IBDesignable
class PrescriptionLineEntry: UIView{

  @IBOutlet var contentView:UIView!
  @IBOutlet var addFromContactsButton:UIButton!
  @IBOutlet var showHelpButton:UIButton!
  @IBOutlet var titleLabel:UILabel!
  @IBOutlet var searchTextField:SearchTextField!


  @IBInspectable
  public var title: String = "Title TK" {
    didSet {
      titleLabel?.text = title
    }
  }

  @IBInspectable
  public var placeholder: String = "e.g. Placeholder TK" {
    didSet {
      searchTextField?.placeholder = placeholder
    }
  }

  @IBInspectable
  public var plusButtonHidden: Bool = false {
    didSet {
      addFromContactsButton?.isHidden =  plusButtonHidden
    }
  }

  /// Init for code
  override init(frame: CGRect) { //code
    super.init(frame: frame)
  }

  /// Init for InterfaceBuilder
  required init?(coder aDecoder: NSCoder) { //IB
    super.init(coder:aDecoder)
  }


  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    debugPrint("Prep")
    commonSetup(isFromIB: true)
  }

  override func awakeFromNib() {
    commonSetup()
  }

  var loadedViews:[Any]? = nil
  /// Join all init here
  private func commonSetup(isFromIB:Bool = false){
    let bundle = Bundle(for:PrescriptionLineEntry.self)
    let nib = UINib(nibName: String(describing: PrescriptionLineEntry.self), bundle: bundle)
    nib.instantiate(withOwner: self, options: nil)
    addSubview(contentView)
    setupConstraints()

    //Calls the didset to use the inital values specified in code
    placeholder = {placeholder}()
    plusButtonHidden = {plusButtonHidden}()
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
