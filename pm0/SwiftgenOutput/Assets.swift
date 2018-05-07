// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  enum Colors {
    enum Sip {
      static let sipPictonBlue = ColorAsset(name: "sipPictonBlue")
      static let sipTarawera = ColorAsset(name: "sipTarawera")
    }
    static let vlCellBackgroundCommon = ColorAsset(name: "vlCellBackgroundCommon")
    static let vlDisabledButtonColor = ColorAsset(name: "vlDisabledButtonColor")
    static let vlDisabledTextColor = ColorAsset(name: "vlDisabledTextColor")
    static let vlEditableFieldTextColor = ColorAsset(name: "vlEditableFieldTextColor")
    static let vlEditableTextColor = ColorAsset(name: "vlEditableTextColor")
    static let vlEmptyStateText = ColorAsset(name: "vlEmptyStateText")
    static let vlSecondaryTextColor = ColorAsset(name: "vlSecondaryTextColor")
    static let vlTextBackgroundAreaColor = ColorAsset(name: "vlTextBackgroundAreaColor")
    static let vlTextColor = ColorAsset(name: "vlTextColor")
    static let vlWarmTintColor = ColorAsset(name: "vlWarmTintColor")
    static let vlZebraDarker = ColorAsset(name: "vlZebraDarker")
    static let vlZebraLighter = ColorAsset(name: "vlZebraLighter")
  }
  enum Empty {
    static let emptyDoc = ImageAsset(name: "Empty-Doc")
    static let emptyMyDay = ImageAsset(name: "Empty-MyDay")
    static let emptyRx = ImageAsset(name: "Empty-Rx")
    static let orangeButtonBorder = ImageAsset(name: "orangeButtonBorder")
  }
  enum Fax {
    static let blackAndWhiteLogo = ImageAsset(name: "BlackAndWhiteLogo")
    static let exampleFaxSignature = ImageAsset(name: "ExampleFaxSignature")
    static let faxUpright = ImageAsset(name: "FaxUpright")
    static let qrCodeForCover = ImageAsset(name: "QRCodeForCover")
    static let linkToApp = ImageAsset(name: "linkToApp")
  }
  enum FaxAnim {
    static let faxAnimBackground = ImageAsset(name: "FaxAnimBackground")
    static let faxAnimFaxPage = ImageAsset(name: "FaxAnimFaxPage")
    static let faxAnimForegroundML = ImageAsset(name: "FaxAnimForegroundML")
    static let faxAnimForegroundVL = ImageAsset(name: "FaxAnimForegroundVL")
  }
  enum Lock {
    static let buttonBG = ImageAsset(name: "ButtonBG")
    static let lockBG = ImageAsset(name: "LockBG")
    static let lockPulse = ImageAsset(name: "LockPulse")
  }
  enum Tab {
    static let tabDoc = ImageAsset(name: "Tab-Doc")
    static let tabFaxing = ImageAsset(name: "Tab-Faxing")
    static let tabMyDay = ImageAsset(name: "Tab-MyDay")
    static let tabRx = ImageAsset(name: "Tab-Rx")
  }

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
    Colors.Sip.sipPictonBlue,
    Colors.Sip.sipTarawera,
    Colors.vlCellBackgroundCommon,
    Colors.vlDisabledButtonColor,
    Colors.vlDisabledTextColor,
    Colors.vlEditableFieldTextColor,
    Colors.vlEditableTextColor,
    Colors.vlEmptyStateText,
    Colors.vlSecondaryTextColor,
    Colors.vlTextBackgroundAreaColor,
    Colors.vlTextColor,
    Colors.vlWarmTintColor,
    Colors.vlZebraDarker,
    Colors.vlZebraLighter,
  ]
  static let allImages: [ImageAsset] = [
    Empty.emptyDoc,
    Empty.emptyMyDay,
    Empty.emptyRx,
    Empty.orangeButtonBorder,
    Fax.blackAndWhiteLogo,
    Fax.exampleFaxSignature,
    Fax.faxUpright,
    Fax.qrCodeForCover,
    Fax.linkToApp,
    FaxAnim.faxAnimBackground,
    FaxAnim.faxAnimFaxPage,
    FaxAnim.faxAnimForegroundML,
    FaxAnim.faxAnimForegroundVL,
    Lock.buttonBG,
    Lock.lockBG,
    Lock.lockPulse,
    Tab.tabDoc,
    Tab.tabFaxing,
    Tab.tabMyDay,
    Tab.tabRx,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
