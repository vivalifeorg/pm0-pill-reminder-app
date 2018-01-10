//
//  PrescriptionListViewController
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit

struct DosingSchedule{
  var periodLength:Int
  var dosesPerPeriod:Int
  var isWakeToTake:Bool = false
  var isOnlyForConsumptionWithFood:Bool = false
}

struct Doctor{

}

struct DosageForm{

}

struct Potency{

}

struct Drug{
  var name:String

  var shortName:String{
    return name
  }
}

struct Condition{
  var name:String

  var description:String{
    return name
  }
}

struct MedicationSource{
  var name:String
  var isPharmacy:Bool
  var isHospital:Bool
  var isDoctor:Bool
  var isOverTheCounter:Bool
}

struct Prescription{
  var drug:Drug?
  var strength:Potency?
  var dosageForm:DosageForm?
  var quantityPrescribed:Int?
  var refillsPrescribed:Int?
  var writtenDirections:String?

  var obtainedFrom:MedicationSource?
  var conditionPrescribedFor:Condition?
}

extension Prescription{
  var title:String{
    return drug?.shortName ?? "<Unnamed>"
  }
  var subTitle:String{
    return conditionPrescribedFor.map{"for \($0)"} ?? "for <Condition>"
  }
}

struct PrescriptionListViewModel{
  var prescriptions:[Prescription] = []

  subscript(indexPath:IndexPath)->Prescription{
    return prescriptions[indexPath.row]
  }
}

struct VLColors{
  static var primaryText:UIColor{
    return UIColor.white
  }
  static var secondaryText:UIColor{
    return UIColor.gray
  }
  static var background:UIColor{
    return UIColor.black
  }
  static var warmHighlight:UIColor{
    return UIColor(red:0.92, green:0.60, blue:0.34, alpha:1.00) //porche
  }
  static var coolHighlight:UIColor{
    return UIColor(red:0.29, green:0.68, blue:0.92, alpha:1.00) //picton blue
  }
  static var cellBackground:UIColor{
    return sipTarawera
  }
  static var sipMirage:UIColor{
    return UIColor(red:0.06, green:0.11, blue:0.15, alpha:1.00)
  }

  static var sipTarawera:UIColor{
    return UIColor(red:0.13, green:0.22, blue:0.30, alpha:1.00)
  }

  static var sipPatternsBlue:UIColor{
    return UIColor(red:0.89, green:0.95, blue:0.98, alpha:1.00)
  }

  static var tintColor:UIColor{
    return sipPatternsBlue
  }
}

class PrescriptionListViewController: UIViewController,UITableViewDataSource {
  @IBOutlet weak var tableView: UITableView!

  var viewModel = PrescriptionListViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.tableFooterView?.backgroundColor = VLColors.background
    tableView.dataSource = self
    tableView.backgroundColor = VLColors.background
  }

  @IBAction func addTapped(_ sender: Any) {
    viewModel.prescriptions.append(Prescription())
    tableView.reloadData()
  }

  static var cellIdentifier:String{
    return "PrescriptionListViewControllerCell"
  }

  func tableView(_ tableView:UITableView, cellForRowAt path: IndexPath) ->UITableViewCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: PrescriptionListViewController.cellIdentifier, for:path)
    cell.textLabel?.text = viewModel[path].title
    cell.textLabel?.textColor = VLColors.primaryText
    cell.detailTextLabel?.text = viewModel[path].subTitle
    cell.backgroundColor = VLColors.cellBackground
    view.tintColor = VLColors.tintColor
    return cell
  }

  func numberOfSections(in: UITableView)->Int{
    return 1
  }

  func tableView(_ tableView:UITableView, numberOfRowsInSection: Int)->Int{
    return viewModel.prescriptions.count
  }

  func tableView(_ tableView:UITableView, titleForHeaderInSection: Int)->String?{
    return "Prescriptions"
  }

}

