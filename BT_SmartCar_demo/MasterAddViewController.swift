import UIKit

class MasterAddViewController: UIViewController {
    
    var certiMsg: [UInt8]!
    var timeSet: Int = 180
    var cnt = 0
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var certiNumField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        showingRemainTime()
        
        certiNumField.keyboardType = .numberPad
    }
    
    //인증번호 확인
    @IBAction func sendCertiNum(_ sender: Any) {
        let inputNumber = certiNumField.text
        
        if inputNumber == nil || inputNumber == "" {
            emptyNumberAlert()
        } else if inputNumber == certiNumber {
            print(">> [Master Add] 마스터 등록\n")
            masterAddDialog()
        } else {
            cnt += 1
            if cnt == 3 {
                threeTimeWrongNumberAlert()
                cnt = 0
            } else{
                wrongNumberAlert()
            }
        }
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
    
    func masterAddDialog(){
        let alert = UIAlertController(title: "마스터 등록", message: NSLocalizedString("master add msg2", comment: ""), preferredStyle: .alert)
        
        let buttonAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
            let sData = [0x05] + self.certiMsg + [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            
            print(">>[Master Add] Certi num 보냄: \(sData.toHexString())")
            self.sendRequestData(cmd: RESPONSE_CERT_NUM_CMD, data: sData)

            self.dismiss(animated: true)
        })
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //암호화해서 데이터를 보내는 함수
    func sendRequestData(cmd: [UInt8], data: [UInt8]){
        var sendDataByte: [UInt8] = []
        
        let encryptData = AES128Util().setAES128Encrypt(bytes: data)
        
        sendDataByte += cmd
        sendDataByte += encryptData
        
        serial.sendBytesToDevice(sendDataByte)
    }
}
