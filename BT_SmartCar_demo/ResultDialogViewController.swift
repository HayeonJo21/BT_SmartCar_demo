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
        NumberCertificationViewController().result_showing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.dismissView), name: .broadcaster_4, object: nil)
    }
    
    @objc func dismissView(){
        if controllerFlag == 1 {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func okButton(_ sender: Any) {
        showing2 = false
        
        if sf {
            print("정보 저장 후 control view로 이동\n")
            
            let controlVC = ControlViewController.init(nibName: "ControlViewController", bundle: nil)
            
            controlVC.connectedPeripheral = self.connectedPeripheral
            controlVC.devUser = user
            
            if user < 3 {
                print("Result Dialog: 사용자 정보 저장 Preference \n")
                preferences.set(login, forKey: phoneMacAddr)
                emailPreferences.set(Email_id, forKey: phoneMacAddr + "eid")
                emailPreferences.set(Email_addr, forKey: phoneMacAddr + "addr")

            }
            
            let didSave1 = preferences.synchronize()
            let didSave2  = emailPreferences.synchronize()
            
            if !didSave1 || !didSave2 {
                emptySettingInfoAlert()
            }
            
            controlVC.modalPresentationStyle = .fullScreen
            self.present(controlVC, animated: true)
            
            
        } else {
            self.dismiss(animated: true)
            print("loginViewController finish\n")
        }
    }
    
    /**
     Alert 함수
     */
    func emptySettingInfoAlert(){
        let alert = UIAlertController(title: NSLocalizedString("empty info", comment: ""), message: NSLocalizedString("empty info msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
            phoneNumVC.modalPresentationStyle = .formSheet
            self.present(phoneNumVC, animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
