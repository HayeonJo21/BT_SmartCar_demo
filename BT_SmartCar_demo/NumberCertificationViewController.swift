
import UIKit
import CoreBluetooth

class NumberCertificationViewController: UIViewController {
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    var connectedPeripheral: CBPeripheral!
    
    @IBAction func tapGesture(_ sender: Any) {
        view.endEditing(true)
    }
    
    var user_email: String!
    var timeSet: Int = 180 // 입력 제한시간 3분
    var cnt = 0
    var result_showing = false
    var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setKeyboardObserver()

        numberTextField.keyboardType = .default
        
        sendEmailAlert()
        showingRemainTime()
        
        view.endEditing(true)

        NotificationCenter.default.addObserver(self, selector: #selector(self.checkingCertiNum), name: .broadcaster_1, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "BluetoothLE Smart Car Service"
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //인증번호 확인
    @IBAction func numberConfirm(_ sender: Any) {
        
        guard let inputText = numberTextField.text else { return }
        
        let hexaData = stringToHex0x(data: inputText) + makingStringLength16(str: inputText)
        let parseData = makingHexStringToByteArray(str: hexaData)
        
        let aes128 = AES128Util().setAES128Encrypt(bytes: parseData)
        
        let sendingData = [0x61] + aes128
        
        print("[Number Certification] 입력된 인증번호 전송(original): \(hexaData)\n")
        
        serial.sendBytesToDevice(sendingData)
        
        LoadingSerivce.showLoading()
        
        //observer해제
        view.endEditing(true)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
   @objc func checkingCertiNum(){
        let cmd = parseHexCode(bytes: response)
        
        if response.endIndex > 2 {
            for i in resultData.startIndex..<resultData.endIndex {
                resultData[i] = response[i + 1]
            }
        }
        
        let decryptData = AES128Util().getAES128Decrypt(encoded: resultData)
        
        if cmd.caseInsensitiveCompare("C1") == .orderedSame {
            if !result_showing {
                if decryptData[0] == 0x01 {
                    if decryptData[1] == 0x02 {
                        transition(msg: "추가 사용자 등록을 완료했습니다.", sf: true, user: 2)
                    } else if decryptData[1] == 0x03 {
                        transition(msg: "임시 사용자 등록을 완료했습니다.", sf: true, user: 3)
                    } else if decryptData[1] == 0x01 {
                        transition(msg: "마스터 사용자 변경을 완료했습니다.", sf: true, user: 1)
                    }
                }else {
                    transition(msg: "등록을 실패했습니다.", sf: false, user: 4)
                }
            } 
        }
    }
    
    func transition(msg: String, sf: Bool, user: Int) {
        let resultVC = ResultDialogViewController.init(nibName: "ResultDialogViewController", bundle: nil)
        LoadingSerivce.hideLoading()
        resultVC.msg = msg
        resultVC.user = user
        resultVC.sf = sf
        resultVC.connectedPeripheral = self.connectedPeripheral
        
        self.present(resultVC, animated: true)
    }
    
    
    //남은 시간 표시
    func showingRemainTime(){
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            self.timeSet -= 1
            
            let min = self.timeSet / 60
            let sec = self.timeSet % 60
            
            if self.timeSet > 0 {
                self.timeLabel.text = "⏰ \(min)분 \(sec)초 남음"
            }else{
                self.timeLabel.text = "인증 시간 만료"
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //alert 함수
    func sendEmailAlert(){
        let alert = UIAlertController(title: NSLocalizedString("sending email", comment: ""), message: NSLocalizedString("sending email msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func emptyNumberAlert(){
        let alert = UIAlertController(title: "입력 오류", message: "인증번호 6자리를 입력해주세요.", preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func wrongNumberAlert(){
        let alert = UIAlertController(title: "입력 오류", message: "인증번호가 틀렸습니다.", preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func threeTimeWrongNumberAlert(){
        let alert = UIAlertController(title: "입력 오류", message: "인증번호를 3회 틀렸습니다. 처음단계로 돌아갑니다.", preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
