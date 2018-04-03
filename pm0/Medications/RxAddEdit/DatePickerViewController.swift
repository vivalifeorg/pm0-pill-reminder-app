//For original for this file:
//The MIT License (MIT)
//
//Copyright (c) 2018 Roman Volodko <roman.volodko@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

//For portions of this file:
//
//  DatePickerViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/3/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

extension UIAlertController {
  /// Set alert's content viewController
  ///
  /// - Parameters:
  ///   - vc: ViewController
  ///   - height: height of content viewController
  func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
    guard let vc = vc else { return }
    setValue(vc, forKey: "contentViewController")
    if let height = height {
      vc.preferredContentSize.height = height
      preferredContentSize.height = height
    }
  }

  /// Add a date picker
  ///
  /// - Parameters:
  ///   - mode: date picker mode
  ///   - date: selected date of date picker
  ///   - minimumDate: minimum date of date picker
  ///   - maximumDate: maximum date of date picker
  ///   - action: an action for datePicker value change

  func addDatePicker(mode: UIDatePickerMode, date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, action: DatePickerViewController.Action?) {
    let datePicker = DatePickerViewController(mode: mode, date: date, minimumDate: minimumDate, maximumDate: maximumDate, action: action)
    set(vc:datePicker, height: 217)
  }
}

final class DatePickerViewController: UIViewController {

  public typealias Action = (Date) -> Void

  fileprivate var action: Action?

  fileprivate lazy var datePicker: UIDatePicker = { [unowned self] in
    $0.addTarget(self, action: #selector(DatePickerViewController.actionForDatePicker), for: .valueChanged)
    return $0
    }(UIDatePicker())

  required init(mode: UIDatePickerMode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, action: Action?) {
    super.init(nibName: nil, bundle: nil)
    datePicker.datePickerMode = mode
    datePicker.date = date ?? Date()
    datePicker.minimumDate = minimumDate
    datePicker.maximumDate = maximumDate
    self.action = action
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = datePicker
  }

  @objc func actionForDatePicker() {
    action?(datePicker.date)
  }

  public func setDate(_ date: Date) {
    datePicker.setDate(date, animated: true)
  }
}
