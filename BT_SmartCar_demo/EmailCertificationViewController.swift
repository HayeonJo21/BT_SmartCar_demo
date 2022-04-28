import UIKit
import CoreBluetooth

class EmailCertificationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    var selectedDevice: DeviceModel!
    var selectedPeripheral: CBPeripheral!
    var keyFlag = false
    var certiuser = 0
    
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKeyboardObserver()
        
        emailTextField.keyboardType = .emailAddress
        
        self.title = "BluetoothLE Smart Car Service"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        titleLabel.textColor = .white
        deviceName.textColor = .white
        
        deviceName.text = selectedDevice.name
        
        sendConnectingData()
        receivingData()
        
    }
    
    func sendConnectingData(){
        let msg: [UInt8] = [0x11, 0x02, 0x43, 0x4F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        keyFlag = false
        
        print(">> [EmailCertification] 연결후 이메일 인증에서 보내는 메시지 : \(msg.toHexString()) \n")
        serial.sendBytesToDevice(msg)
    }
    
    //EmailCertification
    func receivingData(){
        var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
        let cmd = parseHexCode(bytes: response)
        
        if response.endIndex > 2 {
            for i in resultData.startIndex..<resultData.endIndex {
                resultData[i] = response[i + 1]
            }
        }
        
        print(">> [EmailCertification] 응답 Bytes: \(response.description)")
        print(">> [EmailCertification] 응답 Hex: \(response.toHexString())")
        print(">> [EmailCertification] 가공한 응답: \(resultData.toHexString())")
        print(">> [EmailCertification] 커맨드: \(cmd) \n")
        
        if cmd == "00" {
            print("Bluetooth alert")
            serial.manager.cancelPeripheralConnection(selectedPeripheral)
            bluetoothErrorAlert()
        }else if cmd.caseInsensitiveCompare("A2") == ComparisonResult.orderedSame {
            if (response[1] == 0x01) && (response[2] == 0x0F) {
                //TODO: 전달받은 키값이 맞다면 키값 적용
                print("키값 적용\n")
                CIPHER_KEY = TEMP_KEY
            } else if (response[1] == 0x02) && (response[2] == 0x0F) {
                //전달받은 키값이 다름
                print("전달 받은 키값이 다름\n")
                serial.manager.cancelPeripheralConnection(selectedPeripheral)
                keyValueAlert()
            }else{
                if !keyFlag { //key값 저장
                    keyFlag = true
                    
                    TEMP_KEY = resultData
                    CIPHER_KEY = resultData
                    print("[Key값 저장]" + resultData.debugDescription)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        print(">> [EmailCertification] 키값 저장 후 데이터 보냄\n")
                        let data = [0xA2] + resultData
                        print(">>> data: \(data.toHexString())")
                        serial.sendBytesToDevice(data)
                    }
                } else {
                    print("키값이 저장되지 않음")
                }
            }
        } else if response[0] == 0x51 {
            if certiuser == 1 {
                print("-------- 0x51 - ok | send email address")
                certiuser = 2
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    print(">> [EmailCertification] 0x52 데이터 보냄\n")
                    let emailItem = stringToHex0x(data: Email_addr) + makingStringLength16(str: Email_addr)
                    
                    let emailHexaItem = makingHexStringToByteArray(str: emailItem)
                    
                    let aes128 = AES128Util().setAES128Encrypt(bytes: emailHexaItem)
                    
                    let cmdPacket:[UInt8] = [0x52]
                    
                    let sendingData = (cmdPacket + aes128)
                    serial.sendBytesToDevice(sendingData)
                }
            }
        } else if response[0] == 0x52 {
            if certiuser == 2 {
                print("-------- 0x52 - ok | send phone number")
                certiuser = 3
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    print(">> [EmailCertification] 0x53 데이터 보냄\n")
                    let phoneItem = stringToHex0xWithoutLength(data: phoneNumber) + makingStringLength16(str: phoneNumber)
                    
                    let phoneHexaItem = makingHexStringToByteArray(str: phoneItem)
                    
                    let aes128 = AES128Util().setAES128Encrypt(bytes: phoneHexaItem)
                    
                    let cmdPacket:[UInt8] = [0x53]
                    
                    let sendingData = (cmdPacket + aes128)
                    serial.sendBytesToDevice(sendingData)
                }
            }
        }
    }
    
    @IBAction func certiBtn(_ sender: Any) {
        
        if let email = emailTextField.text {
            if isValidEmail(testStr: email){
                
                user_email = email
                
                let emailArr = email.components(separatedBy: "@")
                Email_id = emailArr[emailArr.startIndex]
                Email_addr = emailArr[emailArr.startIndex + 1]
                
                
                print("Email Slicing: \(Email_id)")
                print("Email Hex: \(stringToHex0x(data: Email_id))\n")
                
                
                //AES128
                let emailItem = stringToHex0x(data: Email_id) + makingStringLength16(str: Email_id)
                
                print(">>> 이메일 Hexadecimal : \(emailItem)")
                
                let emailHexaItem = makingHexStringToByteArray(str: emailItem)
                
                let aes128 = AES128Util().setAES128Encrypt(bytes: emailHexaItem)
                print(">>> 암호화된 이메일: \(aes128.debugDescription)\n")
                print(">>> 암호화된 이메일 (hex): \(aes128.toHexString())\n")
                
                
                let cmdPacket:[UInt8] = [0x51]
                
                let sendingData = (cmdPacket + aes128)
                
                //전송
                print(">> [EmailCertification] 이메일 데이터 전송 : \(sendingData.description) \n ")
                print(">> [EmailCertification] 이메일 데이터 전송 (Hex string) : \(sendingData.toHexString()) \n ")
                serial.sendBytesToDevice(sendingData)
                
                
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
    
    func keyValueAlert(){
        let alert = UIAlertController(title: NSLocalizedString("key value", comment: ""), message: NSLocalizedString("key value msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
