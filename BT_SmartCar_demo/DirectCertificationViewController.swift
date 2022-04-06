import UIKit
import CoreBluetooth

class DirectCertificationViewController: UIViewController {

    @IBOutlet weak var directMsg: UILabel!
    @IBOutlet weak var loadingImg: UIImageView!
    var selectedPeripheral: CBPeripheral!
    var flag = 0
    let AESUtil = AES128Util()
    var userLevel = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        checkConnectingStatus()
    }
    
    
    func checkConnectingStatus(){
        let status = selectedPeripheral.state
        
        if status == .connected {
            print("Connected")
            flag = 1
        } else if status == .connecting {
            directMsg.text = "연결 중 입니다."
            checkConnectingStatus()
        } else if status == .disconnected || status == .disconnecting {
            loadingImg.tintColor = .red
            directMsg.text = "기기와의 연결을 다시 시도 중입니다."
            serial.connectToPeripheral(selectedPeripheral)
        } else {
            failureAlert()
        }
    }
    
    //암호화해서 데이터를 보내는 함수
    func sendRequestData(cmd: String, data: String){
        directMsg.text = "연결 시도 중입니다..."

        var sendDataByte: [UInt8] = []
        
        let encryptData = AESUtil.setAES128Encrypt(string: data)
        
        sendDataByte += cmd.bytes
        sendDataByte += encryptData.bytes
        
        serial.sendBytesToDevice(sendDataByte)
        
    }
    
    // 응답을 받아 처리하는 부분
    func decryptDataAndAction(response: [UInt8]){
        let decryptData = AESUtil.getAES128Decrypt(encoded: response.toBase64()).bytes
        let cmd = parseCMDCode(bytes: response)
        let type = parseCMDCode(bytes: decryptData)
        
        if response.isEmpty {
            return
        }
        
        switch cmd {
        case "00":
            break
        case "A2":
            if response[1] == 0x01 && response[2] == 0x0F { //전달 받은 키값이 맞다면 키값 적용
                directMsg.text = "연결 진행 중입니다..."
                //TODO: 인증데이터 전송(async 사용?)
            } else if response[1] == 0x02 && response[2] == 0x0F { //전달 받은 키값이 다름
                //disconncet
                //TODO: 연결 끊고 loginView로 넘어감
            } else {
                //TODO: cmd가 0xA2인 데이터 전송, key값 저장
                // DirectCertification.java 260행 참고
            }
            break
            
        case "51":
            //TODO: 인증정보 request -> 0x51 (개인)
            //sending email, phoneNumber, MAC
            break
            
        case "52":
            //TODO: 인증정보 request -> 0x52 (공유)
            //sending phoneNumber, MAC, 시간정보
            break
            
        case "B1":
            if response[1] == 0x03 || response[1] == 0x04 {
                if response[1] == 0x03 {
                    userLevel = 1
                }else if response[1] == 0x04 {
                    userLevel = 2
                }
                
                directMsg.text = "인증이 완료되었습니다!"
                //TODO: Mac 주소와 User Level을 ControlView로 전달하면서 화면 전환
            } else {
                directMsg.text = "인증에 실패하였습니다."
                directMsg.textColor = .red
                UserfailureAlert()            }
            break
        default:
            break
        }
    }
    

    func parseCMDCode(bytes: [UInt8]) -> String{
        let data = bytes.toBase64()
        let cmd = data.split(separator: " ")
        
        return String(cmd[0])
    }
    
    func parseHexCode(bytes: [UInt8], cnt: Int) -> String {
        let data = bytes.toHexString()
        let cmd = data.split(separator: " ")
        
        return String(cmd[cnt])
    }
    
    
    /*
     Alert 함수
     */
    func failureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("connect failure", comment: ""), message: NSLocalizedString("connect failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.presentingViewController?.dismiss(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func UserfailureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("user failure", comment: ""), message: NSLocalizedString("user failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.presentingViewController?.dismiss(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    

}
