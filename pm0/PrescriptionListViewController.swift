//
//  PrescriptionListViewController
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//


import DZNEmptyDataSet
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

struct TakeTime{
  var hour:Int
  var minute:Int
}

struct Potency{

}

struct Drug{
  var name:String

  var shortName:String{
    return name
  }

  func timesTaken(for:Date)->[TakeTime]{
    return [TakeTime(hour:7, minute:00)]
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
  var unitStrength:Potency?
  var dosageForm:DosageForm?
  var quantityPrescribed:Int?
  var refillsPrescribed:Int?
  var writtenDirections:String?

  var obtainedFrom:MedicationSource?
  var conditionPrescribedFor:Condition?
}

extension Prescription{
  var title:String{
    return drug?.shortName ?? "Drug Name"
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
  static var highlightedPrimaryText:UIColor{
    return VLColors.sipChathamsBlue
  }
  static var secondaryText:UIColor{
    return UIColor.gray
  }
  static var background:UIColor{
    return UIColor.black
  }

  static var sipPorche:UIColor{
    return UIColor(red:0.92, green:0.60, blue:0.34, alpha:1.00)
  }

  static var sipPictonBlue:UIColor{
    return UIColor(red:0.29, green:0.68, blue:0.92, alpha:1.00) //picton blue
  }
  static var warmHighlight:UIColor{
    return sipPorche
  }
  static var coolHighlight:UIColor{
    return sipPictonBlue
  }
  static var cellBackground:UIColor{
    return sipTarawera
  }
  static var sipChathamsBlue:UIColor{
    return UIColor(red:0.19, green:0.34, blue:0.45, alpha:1.00)
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

  static var selectedCellBackground:UIColor{
    return sipPatternsBlue
  }

  static var tintColor:UIColor{
    return sipPatternsBlue
  }
}


class PrescriptionListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var viewModel = PrescriptionListViewModel()

  @IBAction func unwindToPrescriptionList(segue:UIStoryboardSegue){

    if segue.identifier == "doneEditingPrescription"{
      let prescription = (segue.source as? PrescriptionEntryViewController)?.prescription
      var rx = Prescription()
      let display = "\(prescription?.name ?? prescription?.dosageForm ?? "Drug") \(prescription?.userCount ?? "1") x \(prescription?.drugUnitSummary ?? "dose")"

      rx.drug = Drug(name: display)
      viewModel.prescriptions.append(rx)
      global_allDrugs = viewModel.prescriptions.flatMap{$0.drug}
      tableView.reloadData()
    }
  }


  @IBAction func addTapped(_ sender:UIButton){
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.tableFooterView?.backgroundColor = VLColors.background
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = VLColors.background
    tableView.separatorColor = UIColor.lightGray
    tableView.sectionHeaderHeight = 40
    tableView.emptyDataSetSource = self;
    tableView.emptyDataSetDelegate = self;
  }

  static var cellIdentifier:String{
    return "PrescriptionListViewControllerCell"
  }
}


extension PrescriptionListViewController: UITableViewDelegate,UITableViewDataSource{

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.textLabel?.textColor = VLColors.primaryText
    header.textLabel?.font = UIFont.boldSystemFont(ofSize: 40)
    header.textLabel?.frame = header.frame
    header.textLabel?.text = "Prescriptions"
  }

  func tableView(_ tableView:UITableView, cellForRowAt path: IndexPath) ->UITableViewCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: PrescriptionListViewController.cellIdentifier, for:path)
    cell.textLabel?.text = viewModel[path].title
    cell.detailTextLabel?.text = viewModel[path].subTitle

    //let isSelected = tableView.indexPathsForSelectedRows?.contains(path) ?? false
    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
    cell.textLabel?.textColor = VLColors.primaryText
    cell.textLabel?.highlightedTextColor = VLColors.highlightedPrimaryText
    cell.detailTextLabel?.textColor = VLColors.secondaryText

    cell.backgroundColor = VLColors.cellBackground
    let selectedBG = UIView()
    selectedBG.backgroundColor  = VLColors.selectedCellBackground
    cell.selectedBackgroundView = selectedBG

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

extension PrescriptionListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
  func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
    return UIImage(named:"RxEmptyState")
  }

  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "No prescriptions (yet)")
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string:"Tap the + button below to add one.")
  }
}


