import UIKit
import CoreBluetooth

let emailPreferences = UserDefaults.standard
class ResultDialogViewController: UIViewController {

    var sf: Bool!
    var msg: String!
    var user: Int!
    var connectedPeripheral: CBPeripheral!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageOK = UIImage(named: "icon_ok.png")
        let imageIssue = UIImage(named: "icon_issue.png")
        
        if sf {
            resultImg.image = imageOK
        }else {
            resultImg.image = imageIssue
        }
        
        resultLabel.text = msg
        
        showing2 = true
        //NumberCertification result_showing -> true로
        NumberCertificationViewController().result_showing = true
    }

    @IBAction func okButton(_ sender: Any) {
        showing2 = false
        
        if sf {
            print("정보 저장 후 control view로 이동\n")

            let controlVC = ControlViewController.init(nibName: "ControlViewController", bundle: nil)
            
            controlVC.connectedPeripheral = self.connectedPeripheral
            
            if user < 3 {
                preferences.set("in", forKey: phoneMacAddr)
                emailPreferences.set(Email_id + Email_addr, forKey: phoneMacAddr)
            }
            
            _ = preferences.synchronize()
            _ = emailPreferences.synchronize()
            
            self.navigationController?.pushViewController(controlVC, animated: true)
            
        } else {
            self.dismiss(animated: true)
            print("loginViewController finish\n")
        }
    }
    
}
