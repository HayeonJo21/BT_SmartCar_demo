
import UIKit

class NumberCertificationViewController: UIViewController {
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    
    var user_email: String!
    var timeSet: Int = 180 // 입력시간은 3분
    var cnt = 0
    var result_showing = false
    var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextField.keyboardType = .default
        
        sendEmailAlert()
        showingRemainTime()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "BluetoothLE Smart Car Service"
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    //인증번호 확인
    @IBAction func numberConfirm(_ sender: Any) {
        
        if response.endIndex > 2 {
            for i in resultData.startIndex..<resultData.endIndex {
                resultData[i] = response[i + 1]
            }
        }
        
        //복호화
        let decryptData = AES128Util().getAES128Decrypt(encoded: resultData)
        
        
        let inputNumber = numberTextField.text
        
        if inputNumber == nil || inputNumber == "" {
            emptyNumberAlert()
        } else if inputNumber == certiNumber {
            if !result_showing {
                if decryptData[0] == 0x01 {
                    if decryptData[1] == 0x02 {
                        print("추가, 임시 사용자 등록 완료\n")
                    }else if decryptData[1] == 0x03 {
                        print("임시 사용자 등록 완료\n")
                    }else if decryptData[1] == 0x01 {
                        print("마스터 사용자 변경 완료\n")
                    }
                } else {
                    print("등록 실패\n")
                }

            }
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
    
}
