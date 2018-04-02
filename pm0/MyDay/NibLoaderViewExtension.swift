//
//  NibLoaderViewExtension.swift
//  pm0
//
//  Created by Michael Langford on 3/26/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//
import UIKit

extension UIView {
  ///from https://www.prolificinteractive.com/2017/06/09/xib-awakening-uniform-way-load-xibs/


  /// Helper method to init and setup the view from the Nib.
  func xibSetup() {
    let view = loadFromNib()
    addSubview(view)
    stretch(view: view)
  }

  /// Method to init the view from a Nib.
  ///
  /// - Returns: Optional UIView initialized from the Nib of the same class name.
  func loadFromNib<T: UIView>() -> T {
    let selfType = type(of: self)
    let bundle = Bundle(for: selfType)
    let nibName = String(describing: selfType)
    let nib = UINib(nibName: nibName, bundle: bundle)

    guard let view = nib.instantiate(withOwner: self, options: nil).first as? T else {
      fatalError("Error loading nib with name \(nibName)")
    }

    return view
  }


  /// Stretches the input view to the UIView frame using Auto-layout
  ///
  /// - Parameter view: The view to stretch.
  func stretch(view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: topAnchor),
      view.leftAnchor.constraint(equalTo: leftAnchor),
      view.rightAnchor.constraint(equalTo: rightAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor)
      ])
  }
}
