import UIKit
import CoreBluetooth

class DirectCertificationViewController: UIViewController {
    
    @IBOutlet weak var directMsg: UILabel!
    @IBOutlet weak var loadingImg: UIImageView!
    var selectedPeripheral: CBPeripheral!
    var device: DeviceModel!
    
    var flag = 0
    var keyFlag = false
    var msgFlag = false
    
    let AESUtil = AES128Util()
    var certiuser = 0
    
    var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        view.isUserInteractionEnabled = false
        
        //연결 메시지 보냄
        print(">> [Direct Certification] 연결 메시지 보냄.. \n")
        self.sendConnectingData()
        LoadingSerivce.showLoading()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.decryptDataAndAction), name: .broadcaster_3, object: nil)
        
    }
    
    //연결 메시지 보냄
    func sendConnectingData(){
        let msg: [UInt8] = [0x11, 0x02, 0x43, 0x4F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        
        keyFlag = false
        
        print(">> [Direct Certification] 연결 후 보내는 메시지 : \(msg.toHexString()) \n")
        
        if selectedPeripheral.state == .connected{
            serial.sendBytesToDevice(msg)
        }else{
            print("!!! [Direct Certification] 블루투스 연결이 끊김/n")
            disconnectedAlert()
        }
    }
    
    // 응답을 받아 처리하는 부분
    @objc func decryptDataAndAction(){
        LoadingSerivce.showLoading()
        
        let cmd = parseHexCode(bytes: response)
        
        if response.endIndex > 2 {
            for i in resultData.startIndex..<resultData.endIndex {
                resultData[i] = response[i + 1]
            }
        }
        
        //복호화
        let decryptData = AES128Util().getAES128Decrypt(encoded: resultData)
        print("---- [Direct Certification] 응답 복호화: \(logParsing(str: decryptData.toHexString()))\n")
        
        //블루투스 상태
        let status = selectedPeripheral.state
        
        if status == .connected {
            print("Connected")
            flag = 1
        } else if status == .connecting {
            directMsg.text = "블루투스 연결 중 입니다."
        } else if status == .disconnected || status == .disconnecting {
            loadingImg.tintColor = .red
            directMsg.text = "기기와의 연결을 다시 시도 중입니다."
            serial.connectToPeripheral(selectedPeripheral)
        } else {
            failureAlert()
        }
        
        //응답에 따른 처리
        switch cmd{
        case "00":
            break
        case "A2", "a2":
            if (response[1] == 0x01) && (response[2] == 0x0F) && keyFlag == true{
                print("키값 적용\n")
                directMsg.text = "연결 진행 중입니다..."
                LoadingSerivce.hideLoading()
                CIPHER_KEY = TEMP_KEY
                
                if emailPreferences.object(forKey: phoneMacAddr + "eid") != nil {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.certiuser = 1
                        Email_id = emailPreferences.object(forKey: phoneMacAddr + "eid") as! String
                        //AES128
                        let emailItem = stringToHex0x(data: Email_id) + makingStringLength16(str: Email_id)
                        
                        print(">>> 이메일 Hexadecimal : \(emailItem)")
                        
                        let emailHexaItem = makingHexStringToByteArray(str: emailItem)
                        
                        let cmdPacket:[UInt8] = [0x51]
                        
                        print(">> [Direct Certification] 이메일 데이터 전송\n ")
                        self.sendRequestData(cmd: cmdPacket, data: emailHexaItem)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                        self.directMsg.text = "인증 데이터를 전송 중입니다...(2)"
                    }
                }
            } else if (response[1] == 0x02) && (response[2] == 0x0F) {
                //전달받은 키값이 다름
                LoadingSerivce.hideLoading()
                serial.manager.cancelPeripheralConnection(selectedPeripheral)
                keyValueAlert()
            }else{
                if !keyFlag { //key값 저장
                    keyFlag = true
                    
                    TEMP_KEY = resultData
                    print("[Key값 저장] \(logParsing(str: resultData.toHexString()))\n")
                    
                    if self.selectedPeripheral.state == .connected {
                        LoadingSerivce.hideLoading()
                        keyConfirmAlert()
                        
                    }else{
                        print("[Direct Certification] 연결이 끊어짐\n")
                        self.disconnectedAlert()
                    }
                } else {
                    print("키값이 저장되지 않음\n")
                    savingKeyFailAlert()
                }
            }
            break
            
        case "51":
            if certiuser == 1 {
                print("--------------- 0x51 ok | send email address \n")
                certiuser = 2
                
                if emailPreferences.object(forKey: phoneMacAddr + "addr") != nil {
                    
                    Email_addr = emailPreferences.object(forKey: phoneMacAddr + "addr") as! String
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let emailItem = stringToHex0x(data: Email_addr) + makingStringLength16(str: Email_addr)
                        
                        //sending data
                        let emailHexaItem = makingHexStringToByteArray(str: emailItem)
                        let cmdPacket:[UInt8] = [0x52]
                        
                        self.sendRequestData(cmd: cmdPacket, data: emailHexaItem)
                        
                        self.directMsg.text = "인증 데이터를 전송 중입니다...(3)"
                    }
                }
            }
            
            break
            
        case "52":
            if certiuser == 2 {
                print("--------------- 0x52 ok | send phone number \n")
                certiuser = 3
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    //sending data
                    let phoneItem = stringToHex0xWithoutLength(data: phoneNumber) + makingStringLength16(str: phoneNumber)
                    
                    let phoneHexaItem = makingHexStringToByteArray(str: phoneItem)
                    let cmdPacket:[UInt8] = [0x53]
                    
                    self.sendRequestData(cmd: cmdPacket, data: phoneHexaItem)
                    self.directMsg.text = "인증 데이터를 전송 중입니다...(4)"
                    
                }
            }
            break
            
        case "53":
            if certiuser == 3 {
                print("--------------- 0x53 - ok | send Mac Address")
                certiuser = 4
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    //sending data
                    let macPacket = parsingMacAddress(mac: phoneMacAddr) + [0x00, 0x00, 0x00, 0x00, 0x00]
                    let cmdPacket:[UInt8] = [0x54]
                    self.sendRequestData(cmd: cmdPacket, data: macPacket)
                    self.directMsg.text = "인증 데이터를 전송 중입니다...(5)"
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.msgFlag = true
                }
                
            } else if certiuser == 4 {
                if msgFlag{
                    //TODO: retry 해도 되고 안해도 되고
                    errorAlert()
                }
            }
            break
            
        case "B1", "b1":
            LoadingSerivce.hideLoading()
            if decryptData[1] == 0x03 || decryptData[1] == 0x04 {
                var cuser = 2
                if decryptData[1] == 0x03 {
                    cuser = 1
                }else if decryptData[1] == 0x04 {
                    cuser = 2
                }
                directMsg.text = "인증이 완료되었습니다!"
                // ControlView로 화면 전환
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let controlVC = ControlViewController.init(nibName: "ControlViewController", bundle: nil)
                    
                    controlVC.connectedPeripheral = self.selectedPeripheral
                    controlVC.devUser = cuser
                    
                    controlVC.modalPresentationStyle = .fullScreen
                    self.present(controlVC, animated: true)
                }
                
            } else {
                directMsg.text = "인증에 실패하였습니다."
                directMsg.textColor = .red
                UserfailureAlert()
            }
            break
            
        default:
            break
        }
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
     Alert 함수
     */
    func failureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("connect failure", comment: ""), message: NSLocalizedString("connect failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            serial.manager.cancelPeripheralConnection(self.selectedPeripheral)
            self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func UserfailureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("user failure", comment: ""), message: NSLocalizedString("user failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            serial.manager.cancelPeripheralConnection(self.selectedPeripheral)
            self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func keyValueAlert(){
        let alert = UIAlertController(title: NSLocalizedString("key value", comment: ""), message: NSLocalizedString("key value msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            serial.manager.cancelPeripheralConnection(self.selectedPeripheral)
            self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }

    func savingKeyFailAlert(){
        let alert = UIAlertController(title: NSLocalizedString("saving key fail", comment: ""), message: NSLocalizedString("saving key fail msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func keyConfirmAlert(){
        let alert = UIAlertController(title: NSLocalizedString("key confirm", comment: ""), message: NSLocalizedString("key confirm msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            print(">> [EmailCertification] 키값 확인 테스트\n")
            LoadingSerivce.showLoading()
            let data = [0xA2] + self.resultData
            print(">>> data: \(data.toHexString())")
            serial.sendBytesToDevice(data)
        })
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    func disconnectedAlert(){
        
        let alert = UIAlertController(title: NSLocalizedString("disconnected alert", comment: ""), message: NSLocalizedString("disconnected alert msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    func errorAlert(){
        let alert = UIAlertController(title: NSLocalizedString("error alert", comment: ""), message: NSLocalizedString("error alert msg", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popToRootViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
