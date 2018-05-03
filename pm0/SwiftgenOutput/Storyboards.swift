// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum DoctorList: StoryboardType {
    static let storyboardName = "DoctorList"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: DoctorList.self)

    static let doctorEntryViewController = SceneType<pm0.DoctorEntryViewController>(storyboard: DoctorList.self, identifier: "DoctorEntryViewController")

    static let doctorListNav = SceneType<UINavigationController>(storyboard: DoctorList.self, identifier: "DoctorListNav")
  }
  enum FaxStatus: StoryboardType {
    static let storyboardName = "FaxStatus"

    static let initialScene = InitialSceneType<pm0.FaxStatusViewController>(storyboard: FaxStatus.self)

    static let faxStatusScreen = SceneType<pm0.FaxStatusViewController>(storyboard: FaxStatus.self, identifier: "FaxStatusScreen")
  }
  enum FaxableDocuments: StoryboardType {
    static let storyboardName = "FaxableDocuments"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: FaxableDocuments.self)

    static let dataFromScreen = SceneType<pm0.SendToViewController>(storyboard: FaxableDocuments.self, identifier: "DataFromScreen")

    static let faxingNav = SceneType<UINavigationController>(storyboard: FaxableDocuments.self, identifier: "FaxingNav")

    static let preview2 = SceneType<pm0.FaxPreviewViewController>(storyboard: FaxableDocuments.self, identifier: "Preview2")

    static let sendToScreen = SceneType<pm0.SendToViewController>(storyboard: FaxableDocuments.self, identifier: "SendToScreen")

    static let sendToViewControllerInMedFlow = SceneType<pm0.SendToViewController>(storyboard: FaxableDocuments.self, identifier: "SendToViewControllerInMedFlow")

    static let medlogFlowRestorationNameController = SceneType<pm0.NameViewController>(storyboard: FaxableDocuments.self, identifier: "medlogFlowRestorationNameController")
  }
  enum HelpViewController: StoryboardType {
    static let storyboardName = "HelpViewController"

    static let initialScene = InitialSceneType<pm0.HelpViewController>(storyboard: HelpViewController.self)
  }
  enum LaunchScreen: StoryboardType {
    static let storyboardName = "LaunchScreen"

    static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)
  }
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let initialScene = InitialSceneType<pm0.LockViewController>(storyboard: Main.self)
  }
  enum PrescriptionEntryViewController: StoryboardType {
    static let storyboardName = "PrescriptionEntryViewController"

    static let prescriptionEntryNav = SceneType<UINavigationController>(storyboard: PrescriptionEntryViewController.self, identifier: "PrescriptionEntryNav")
  }
  enum PrescriptionListViewController: StoryboardType {
    static let storyboardName = "PrescriptionListViewController"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: PrescriptionListViewController.self)
  }
  enum UpcomingDay: StoryboardType {
    static let storyboardName = "UpcomingDay"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: UpcomingDay.self)
  }
}

enum StoryboardSegue {
  enum DoctorList: String, SegueType {
    case canceledDoctorUnwind
    case editDoctor
    case editDoctorSegue
    case newDoctorSegue
    case savedDoctorEditOrNew
    case sendHipaaReleaseFromDoctorViewer
    case sendMedlogFromDoctorViewer
    case unwindFromFaxingAfterCancel
    case viewDoctorSegue
  }
  enum FaxableDocuments: String, SegueType {
    case addDoctorFromSendToScreen = "AddDoctorFromSendToScreen"
    case doneSigning
    case sendInfoFaxSegue
    case sendMedicationLog
    case showFaxStatus
    case showHelpVC
    case unwindFromFaxingAfterCancel
    case unwindFromFaxingAfterSend
  }
  enum Main: String, SegueType {
    case goToApp
    case unwindToStart
  }
  enum PrescriptionEntryViewController: String, SegueType {
    case addCustomScheduleSegue
    case canceledEditingSchedule
    case editTimeslotsSegue
    case savingScheduleSegue
    case showPrescriptionHelp
  }
  enum PrescriptionListViewController: String, SegueType {
    case showHelp
    case showPrescriptionAddEntry
    case showPrescriptionEditEntry
  }
  enum UpcomingDay: String, SegueType {
    case addPrescriptionSegue
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
