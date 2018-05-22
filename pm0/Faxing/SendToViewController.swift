//
//  SendToViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class SendToViewController:UITableViewController, SendableDocumentMetadata, PDFHandler{
  var sendableDocumentDestinations: [DocumentDestination] = []

  @IBOutlet weak var nextButton:UIBarButtonItem!

  var sendableDocumentTopics: [DocumentTopic] = []
  var doctors:[DoctorInfo] = []
  var selectedRows:[IndexPath] = []
  var sendableDocuments:[DocumentRef] = []

  func updateNextButton(){
    nextButton.isEnabled = selectedRows.count > 0
  }

  func prepareToEdit(segue:UIStoryboardSegue, doctorInfoAtIndex:Int){

    let doctorEntryViewController = segue.destination as! DoctorEntryViewController
    doctorEntryViewController.doctor = doctors[doctorInfoAtIndex]
  }

  let hippaFlowSendRestorationIdentifier = "SendToScreen"
  let medlogFlowSendRestorationIdentifier = "SendToViewControllerInMedFlow"
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == StoryboardSegue.FaxableDocuments.editDoctorFromSendToScreen.rawValue{
      prepareToEdit(segue:segue, doctorInfoAtIndex: self.editingDoctorIndex!.row)
      return
    }

    guard var handler = segue.destination as? (PDFHandler & SendableDocumentMetadata) else {
      return //for cancel, etc
    }


    handler.sendableDocumentTopics = sendableDocumentTopics
    
    let selectedDoctors:[DoctorInfo] = selectedRows.map{doctors[$0.row]}
    selectedDoctors.forEach{ handler.sendableDocumentTopics.append($0) }

    handler.sendableDocumentDestinations = isSendToScreen ?
        selectedDoctors.map{DocumentDestination(name:$0.name, value:$0.fax.number)} :
        sendableDocumentDestinations


    handler.sendableDocuments = sendableDocuments 
  }

  var isSendToScreen:Bool {
    return [hippaFlowSendRestorationIdentifier,
            medlogFlowSendRestorationIdentifier].contains(restorationIdentifier!)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return doctors.count
  }

  override func viewWillAppear(_ animated: Bool) {
    doctors = LocalStorage.DoctorStore.load()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //remove excess lines
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    updateNextButton()
  }



  var alert:UIAlertController?

  var editingDoctorIndex:IndexPath?
  func editDoctorQuery(indexPath: IndexPath){
    alert = UIAlertController(title: "Missing Fax Number",
                              message: "This doctor doesn't have a fax number set",
                              preferredStyle: .alert)
    alert?.addAction(UIAlertAction(title: "Add",
                                   style: .default,
                                   handler: { (action) in
      self.editingDoctorIndex = indexPath
      self.performSegue(withIdentifier: StoryboardSegue.FaxableDocuments.editDoctorFromSendToScreen.rawValue, sender: self)
    }))
    alert?.addAction(UIAlertAction(title: "Cancel",
                                   style: .default,
                                   handler:{  (action) in
      self.tableView.deselectRow(at: indexPath, animated: false)
    }))

    present(alert!, animated: true, completion: nil)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isSendToScreen { 
      guard doctors[indexPath.row].fax.number != "" else{
        editDoctorQuery(indexPath:indexPath)
        return
      }
    }

    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
    selectedRows.append(indexPath)
    updateNextButton()
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .none
    selectedRows = selectedRows.filter{ $0 != indexPath }
    updateNextButton()
  }

  var cellIdentifier:String{
    return isSendToScreen ? "DoctorSelectCell" : "DoctorDataFromSelectCell"
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
    cell.textLabel?.text = doctors[indexPath.row].name
    cell.detailTextLabel?.text = doctors[indexPath.row].specialty
    if isSendToScreen{
      let fax = doctors[indexPath.row].fax
      if  fax.number == ""{
        cell.detailTextLabel?.text = "\(cell.detailTextLabel?.text ?? "") -- No fax number, select to add one"
      }else{
        cell.detailTextLabel?.text = "\(cell.detailTextLabel?.text ?? ""), [Fax: \(doctors[indexPath.row].fax.number)]"
      }
    }

    cell.accessoryType = selectedRows.contains(indexPath) ? .checkmark : .none
    return cell
  }
}

import DZNEmptyDataSet

extension SendToViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
//func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
//  return Asset.Empty.emptyDoc.image
//}

func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
  return emptyStateAttributedString("We need to know more about your doctor first")
}

func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
  let animation  = CABasicAnimation(keyPath:"opacity")
  animation.fromValue = 0.8
  animation.toValue = 1.0
  animation.duration = 3.0
  animation.repeatCount = 5
  animation.autoreverses = true
  animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)

  return animation
}

func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {

  return emptyStateButtonText("Add Doctor")
}



func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {

  return VivaButtonA.createImageForButton(buttonBackgroundColor:Asset.Colors.vlWarmTintColor.color,
                     borderWidth:0.5,
                     cornerRadius: 8,
                     buttonSize: CGSize(width:scrollView.frame.size.width-20, height: 44),
                     backgroundBehindButtonColor: Asset.Colors.vlCellBackgroundCommon.color)
}

func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
  return emptyStateAttributedString("You don't have any doctors saved yet. Add one then we will continue sending a document.")
}

func verticalOffset(forEmptyDataSet scrollView:UIScrollView)->CGFloat{
       return UIDevice.current.model == "iPad" ? 65 : 0
}


func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
  performSegue(withIdentifier: StoryboardSegue.FaxableDocuments.addDoctorFromSendToScreen.rawValue, sender: self)
}

func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
  return true
}

  @IBAction func unwindToDoctorList(segue:UIStoryboardSegue){

    guard segue.identifier == StoryboardSegue.DoctorList.savedDoctorEditOrNew.rawValue else{
      return
    }
    let doctorItem = (segue.source as! DoctorEntryViewController).doctor
    var doctorList = LocalStorage.DoctorStore.load()
    if let editingDoctorIndex = editingDoctorIndex {
      doctorList[editingDoctorIndex.row] = doctorItem
    } else {
      doctorList.append(doctorItem)
    }
    editingDoctorIndex = nil
    LocalStorage.DoctorStore.save(doctorList)
    doctors = doctorList

    tableView.reloadData()
  }
}

