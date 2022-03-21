import UIKit
import Foundation
import CoreBluetooth

class LoginViewController: UIViewController {
    
    var device: DeviceModel!
    var device_peripheral: CBPeripheral!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceNameLabel.text = device.name
        
        setKeyboardObserver()
        check_isMaster()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "BluetoothLE Smart Car Service"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        titleText.textColor = .white
        deviceNameLabel.textColor = .white
        
        LoadingSerivce.showLoading()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            print(flag.description)
            if flag != 1 {
                LoadingSerivce.hideLoading()
                self.connectFailureAlert()
            } else{
                return
            }
        }
    }
    
    func check_isMaster(){
        
        /*
         등록된 핸드폰일 경우 DirectCertification -> 암호화 킷값 교환 후 자동 인증절차 진행. 인증 성공시 ControlViewController로 전환
         미등록 핸드폰일 경우 -> EmailViewController로 이동해서 암호화 킷값 교환 후 이메일 인증을 위한 데이터 교환
         이메일 발송 시 NumberCertification 전환. 인증 성공시 ControlViewController이동
         **/
        
        if true {
            let controlVC = ControlViewController(nibName: "ControlViewController", bundle: nil)
            controlVC.connectedPeripheral = device_peripheral
            self.navigationController?.pushViewController(controlVC, animated: true)
        }
        
        
        
    }
    
    func connectFailureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("connect failure", comment: ""), message: NSLocalizedString("connect failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
extension UIViewController {
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if self.view.window?.frame.origin.y != 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y += keyboardHeight
                }
            }
        }
    }
}
