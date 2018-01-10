//
//  PerscriptionListViewController
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit

struct DosingSchedule{

}

struct Doctor{

}

struct Pharmacy{

}

struct Potency{

}

struct Drug{
  var isCustom:Bool
  var potency:Potency
}

struct Condition{
  var name:String
}

struct Perscription{
  var schedule:DosingSchedule
  var condition:Condition
  var drug:Drug
  var doctor:Doctor
  var pharmacy:Pharmacy
}

struct PerscriptionListViewModel{
  var perscriptions:[Perscription]
}

class PerscriptionListViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func addTapped(_ sender: Any) {
  }


}

