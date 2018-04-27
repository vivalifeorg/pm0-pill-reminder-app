//
//  PrescriptionLineEntry.swift
//  pm0
//
//  Created by Michael Langford on 2/28/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SearchTextField

protocol LineHelper{
  func showHelp(_ helpInfo:NSAttributedString)
}


extension UIView {
  var parentViewController: UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}


@IBDesignable
class PrescriptionLineEntry: UIView{

  static let lineHeight:CGFloat = 98.0

  @IBOutlet var contentView:UIView!
  @IBOutlet var addFromContactsButton:UIButton!
  @IBOutlet var showHelpButton:UIButton!
  @IBOutlet var titleLabel:UILabel!
  @IBOutlet var searchTextField:SearchTextField!


  var helpInfo:NSAttributedString? = NSAttributedString(string:"TK")
  var helper:LineHelper!

  @IBAction func helpWasTapped(sender:Any){
    guard let helpInfo = helpInfo else {
      return
    }

    helper.showHelp(helpInfo)
  }

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
  public var isPlusHidden: Bool = false {
    didSet {
      addFromContactsButton?.isHidden =  isPlusHidden
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
    contentView?.prepareForInterfaceBuilder()
  }

  override func awakeFromNib() {
    commonSetup()
  }

  /// Join all init here
  private func commonSetup(isFromIB:Bool = false){
    let bundle = Bundle(for:PrescriptionLineEntry.self)
    let nib = UINib(nibName: String(describing: PrescriptionLineEntry.self), bundle: bundle)
    nib.instantiate(withOwner: self, options: nil)
    addSubview(contentView)
    setupConstraints()

    //Calls the didset to use the inital values specified in code
    placeholder = {placeholder}()
    isPlusHidden = {isPlusHidden}()
    title = {title}()
  }

  /// Autolayout setup
  private func setupConstraints(){
    
    translatesAutoresizingMaskIntoConstraints = false
    let views = ["PrescriptionLineEntry":contentView!]
    let metrics = ["FixedHeight":PrescriptionLineEntry.lineHeight]
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
