import UIKit
import CoreBluetooth

class EmailCertificationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    var selectedDevice: DeviceModel!
    var selectedPeripheral: CBPeripheral!
    
    // flag 변수들
    var keyFlag = false
    var msgFlag = false
    var showing = false
    
    var certiuser = 0
    var certiMsg = ""
    
    var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
    let cmd = parseHexCode(bytes: response)
    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.receivingData()
        }
    }
    
//    func sendConnectingData(){
//        let msg: [UInt8] = [0x11, 0x02, 0x43, 0x4F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
//
//        keyFlag = false
//
//        print(">> [EmailCertification] 연결후 이메일 인증에서 보내는 메시지 : \(msg.toHexString()) \n")
//        serial.sendBytesToDevice(msg)
//    }
    
    //EmailCertification
    func receivingData(){
        
        if response.endIndex > 2 {
            for i in resultData.startIndex..<resultData.endIndex {
                resultData[i] = response[i + 1]
            }
        }
        
        //복호화
        let decryptData = AES128Util().getAES128Decrypt(encoded: resultData)
        
        
        print(">> [EmailCertification] 응답: \(logParsing(str: response.toHexString()).description)")
        print(">> [EmailCertification] 응답 복호화: \(logParsing(str: decryptData.toHexString()).description)")
        print(">> [EmailCertification] 커맨드: \(cmd) \n")
        
        
        if cmd.caseInsensitiveCompare("C1") == ComparisonResult.orderedSame {
            if decryptData[0] == 0x01 {
                if decryptData[1] == 0x01 {
                    //TODO: 마스터 사용자 등록 완료 표시
                    print("마스터 사용자 등록 완료 표시")
                }else {
                    //TODO: 등록 실패 표시
                    print("마스터 사용자 등록 실패 표시")
                }
            }
            
        }else if cmd.caseInsensitiveCompare("A2") == ComparisonResult.orderedSame {
            if (response[1] == 0x01) && (response[2] == 0x0F) && keyFlag == true{
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
                    print("[Key값 저장] \(logParsing(str: resultData.toHexString()))\n")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if self.selectedPeripheral.state == .connected {
                        print(">> [EmailCertification] 키값 저장 후 데이터 보냄\n")
                        let data = [0xA2] + self.resultData
                        print(">>> data: \(data.toHexString())")
                        serial.sendBytesToDevice(data)
                        }else{
                            print("[EmailCertification] 연결이 끊어짐")
                            self.disconnectedAlert()
                        }
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
                    
                    //sending data
                    let emailHexaItem = makingHexStringToByteArray(str: emailItem)
                    let cmdPacket:[UInt8] = [0x52]
                    
                    self.sendRequestData(cmd: cmdPacket, data: emailHexaItem)
                    
                }
            }
        } else if response[0] == 0x52 {
            if certiuser == 2 {
                print("-------- 0x52 - ok | send phone number")
                certiuser = 3
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    print(">> [EmailCertification] 0x53 데이터 보냄\n")
                    
                    //sending data
                    let phoneItem = stringToHex0xWithoutLength(data: phoneNumber) + makingStringLength16(str: phoneNumber)
                    
                    let phoneHexaItem = makingHexStringToByteArray(str: phoneItem)
                    let cmdPacket:[UInt8] = [0x53]
                    
                    self.sendRequestData(cmd: cmdPacket, data: phoneHexaItem)
                    
                }
            }
        } else if response[0] == 0x53 {
            if certiuser == 3 {
                print("-------- 0x53 - ok | send Mac Address")
                certiuser = 4
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    
                    //sending data
                    let macPacket = parsingMacAddress(mac: phoneMacAddr) + [0x00, 0x00, 0x00, 0x00, 0x00]
                    let cmdPacket:[UInt8] = [0x54]
                    self.sendRequestData(cmd: cmdPacket, data: macPacket)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.msgFlag = true
                }
                
            } else if certiuser == 4 {
                if msgFlag{
                    errorAlert()
                }
            }
        } else {
            if cmd == "00" {
                print("Bluetooth alert")
                serial.manager.cancelPeripheralConnection(selectedPeripheral)
                bluetoothErrorAlert()
            }else if cmd.caseInsensitiveCompare("B1") == .orderedSame { // 인증정보 response(개인)
                if decryptData[1] == 0x05 { //email fail
                    //TODO: email fail alert
                } else if decryptData[1] == 0x01 { //마스터 등록
                    let length = Int(decryptData[0])
                    var certi: [UInt8] = []
                    
                    for i in 0 ..< length {
                        certi[i] = decryptData[i + 3]
                    }
                    certiMsg = certi.toHexString()
                    
                    if !showing {
                        showing = true
                        if decryptData[2] == 0x01 {
                            self.masterAddAlert()
                        }
                    }else {
                        masterAddFailAlert()
                    }
                } else if decryptData[1] == 0x02{ //사용자 등록
                    //TODO: 사용자 등록
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
                
                let cmdPacket:[UInt8] = [0x51]
                
                print(">> [EmailCertification] 이메일 데이터 전송\n ")
                self.sendRequestData(cmd: cmdPacket, data: emailHexaItem)
                
                smtp.send(mail)
                
                let numberCertiVC = NumberCertificationViewController(nibName: "NumberCertificationViewController", bundle: nil)
                
                numberCertiVC.user_email = email
                
                self.navigationController?.pushViewController(numberCertiVC, animated: true)
            }
        }
    }
    
    //Test 버튼 액션 함수
    
    @IBAction func sendingKeyValue(_ sender: Any) {
        print(">> TEST TEST [EmailCertification] 키값 전송 테스트\n")
        let data = [0xA2] + self.resultData
        print(">>> data: \(data.toHexString())")
        serial.sendBytesToDevice(data)
    }
    
    @IBAction func sendingEmailValue(_ sender: Any) {
        if let email = emailTextField.text {
            
            user_email = email
            
            let emailArr = email.components(separatedBy: "@")
            Email_id = emailArr[emailArr.startIndex]
            Email_addr = emailArr[emailArr.startIndex + 1]
            
            
            print("Email Slicing: \(Email_id)")
            print("Email Hex: \(stringToHex0x(data: Email_id))\n")
            
            let emailItem = stringToHex0x(data: Email_id) + makingStringLength16(str: Email_id)
            
            let emailHexaItem = makingHexStringToByteArray(str: emailItem)
            
            let cmdPacket:[UInt8] = [0x51]
            
            print(">> TEST TEST [EmailCertification] 이메일 데이터 전송 테스트\n ")
            self.sendRequestData(cmd: cmdPacket, data: emailHexaItem)
        }
    }
    
    //이메일 유효성 검사 함수
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //암호화해서 데이터를 보내는 함수
    func sendRequestData(cmd: [UInt8], data: [UInt8]){
        var sendDataByte: [UInt8] = []
        
        let encryptData = AES128Util().setAES128Encrypt(bytes: data)
        
        sendDataByte += cmd
        sendDataByte += encryptData
        
        serial.sendBytesToDevice(sendDataByte)
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
    
    func errorAlert(){
        let alert = UIAlertController(title: NSLocalizedString("error alert", comment: ""), message: NSLocalizedString("error alert msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel)
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func disconnectedAlert(){
                
        let alert = UIAlertController(title: NSLocalizedString("disconnected alert", comment: ""), message: NSLocalizedString("disconnected alert msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func masterAddAlert(){
        let alert = UIAlertController(title: NSLocalizedString("master add", comment: ""), message: NSLocalizedString("master add msg", comment: "") + certiMsg, preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel)
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func masterAddFailAlert(){
        let alert = UIAlertController(title: NSLocalizedString("master add fail", comment: ""), message: NSLocalizedString("master add fail msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
