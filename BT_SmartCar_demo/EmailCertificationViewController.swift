import UIKit
import CoreBluetooth

class EmailCertificationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    var selectedDevice: DeviceModel!
    var selectedPeripheral: CBPeripheral!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "BluetoothLE Smart Car Service"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        titleLabel.textColor = .white
        deviceName.textColor = .white
        
        deviceName.text = selectedDevice.name
        
        emailCertification()

    }
    
    //EmailCertification
    func emailCertification(){
        print(">>[Email Certification]<<<")
        var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
        
        if response.endIndex > 2 {
        for i in resultData.startIndex..<resultData.endIndex {
            resultData[i] = response[i + 1]
        }
    }
        
        if response[0] == 0 {
            print("Bluetooth alert")
            serial.manager.cancelPeripheralConnection(selectedPeripheral)
            bluetoothErrorAlert()
        }
    }
    
    @IBAction func certiBtn(_ sender: Any) {
        
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
    
    
    /*
     Alert 함수들
     */

    func bluetoothErrorAlert(){
        let alert = UIAlertController(title: NSLocalizedString("bluetooth error", comment: ""), message: NSLocalizedString("bluetooth error msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
