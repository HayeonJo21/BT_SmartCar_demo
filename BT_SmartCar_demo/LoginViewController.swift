import UIKit
import Foundation
import CoreBluetooth

class LoginViewController: UIViewController{
    
    var device: DeviceModel!
    var device_peripheral: CBPeripheral!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceNameLabel.text = device.name
        
        setKeyboardObserver()
        serial.stopScan()
        
        self.title = "BluetoothLE Smart Car Service"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        titleText.textColor = .white
        deviceNameLabel.textColor = .white
            
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        check_isMaster()

    }
    
    //사용자 정보 체크해서 email, direct로 화면 전환
    func check_isMaster(){
        print("== 사용자 정보 체크 ==")
        if let loginInfo = preferences.object(forKey: phoneMacAddr){
            if loginInfo as! String == login {
                print("=>> [LoginViewController > check_isMaster()] 등록된 핸드폰.")
                
                let directVC = DirectCertificationViewController(nibName: "DirectCertificationViewController", bundle: nil)
                directVC.selectedPeripheral = device_peripheral
                
                directVC.device = device
                
                self.navigationController?.pushViewController(directVC, animated: true)
            } else {
                print("=>> [LoginViewController > check_isMaster()] 미등록 핸드폰.")
                let emailCertiVC = EmailCertificationViewController(nibName: "EmailCertificationViewController", bundle: nil)
                
                emailCertiVC.selectedDevice = device
                emailCertiVC.selectedPeripheral = device_peripheral
                
                self.navigationController?.pushViewController(emailCertiVC, animated: true)
            }
        }else {
            print("=>> [LoginViewController > check_isMaster()] 미등록 핸드폰.")
            let emailCertiVC = EmailCertificationViewController(nibName: "EmailCertificationViewController", bundle: nil)
            
            emailCertiVC.selectedDevice = device
            emailCertiVC.selectedPeripheral = device_peripheral
            
            self.navigationController?.pushViewController(emailCertiVC, animated: true)
        }
        
    }
    
    func check_response(){
        var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
        
        for i in resultData.startIndex..<resultData.endIndex {
            resultData[i] = response[i + 1]
        }
        
        if response[0] == 0 {
            print("Bluetooth alert")
            bluetoothErrorAlert()
        }
    }
    
    //login 버튼을 눌렀을 때 호출
    @IBAction func loginBtn(_ sender: Any) {
        
        if let email = emailTextField.text {
            if isValidEmail(testStr: email){
                
                smtp.send(mail)
                
                let numberCertiVC = NumberCertificationViewController(nibName: "NumberCertificationViewController", bundle: nil)
                
                numberCertiVC.user_email = email
                
                self.navigationController?.pushViewController(numberCertiVC, animated: true)
            }
        }
    }
    
    //이메일 유효성 검사 함수
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    // Alert 함수들
    func connectFailureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("connect failure", comment: ""), message: NSLocalizedString("connect failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func bluetoothErrorAlert(){
        let alert = UIAlertController(title: NSLocalizedString("bluetooth error", comment: ""), message: NSLocalizedString("bluetooth error msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func successConnectionAlert(){
        let connectSuccessAlert = UIAlertController(title: NSLocalizedString("connect success", comment: ""), message: NSLocalizedString("connect success msg", comment: ""), preferredStyle: .actionSheet)
        
        let confirm = UIAlertAction(title: "확인", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
        
        connectSuccessAlert.addAction(confirm)
        self.present(connectSuccessAlert, animated: true, completion: nil)
        
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
