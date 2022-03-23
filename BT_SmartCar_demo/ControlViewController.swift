import UIKit
import CoreBluetooth

class ControlViewController: UIViewController {
    
    var connectedPeripheral: CBPeripheral!
    var start: Bool = false
    let AESUtil = AES128Util()
    
    //status flags
    var horn_push = false
    var open_push = false
    var close_push = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.title = "Control Center"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        DispatchQueue.main.async {
            LoadingSerivce.hideLoading()
        }
    }
    
    func checkStatus(){
        if connectedPeripheral.state == .disconnected {
            print("연결되지 않은 상태")
            disconnectedAlert()
        }
        else if connectedPeripheral.state == .connected {
            print("연결된 상태")
            start = true
        }
    }
    
    //암호화해서 데이터를 보내는 함수
    func sendRequestData(cmd: String, data: String){
        var sendDataByte: [UInt8] = []
        
        let encryptData = AESUtil.setAES128Encrypt(string: data)
        
        sendDataByte += cmd.bytes
        sendDataByte += encryptData.bytes
        
        serial.sendBytesToDevice(sendDataByte)
        
    }
    
    /*
     Click Action 함수들
     */
    @IBAction func doorOpen(_ sender: Any) {
        let cmd = CConfig().REQUEST_DOOR_OPEN_CMD
        let data = CConfig().REQUEST_DOOR_OPEN
        
        open_push = true
        sendRequestData(cmd: cmd, data: data)
    }
    
    @IBAction func doorClose(_ sender: Any) {
        let cmd = CConfig().REQUEST_DOOR_CLOSE_CMD
        let data = CConfig().REQUEST_DOOR_CLOSE
        
        close_push = true
        sendRequestData(cmd: cmd, data: data)
        
    }
    
    @IBAction func carHorn(_ sender: Any) {
        let cmd = CConfig().REQUEST_PANIC_CMD
        let data = CConfig().REQUEST_PANIC
        
        horn_push = true
        sendRequestData(cmd: cmd, data: data)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        serial.manager.cancelPeripheralConnection(connectedPeripheral)
    }
    
    @IBAction func masterDelete(_ sender: Any) {
        
        let cmd = CConfig().REQUEST_MASTER_INIT_CMD
        let data = CConfig().REQUEST_MASTER_INIT
        
        sendRequestData(cmd: cmd, data: data)
    }
    
    
    // 응답을 받아 처리하는 부분
    func decryptDataAndAction(response: [UInt8]){
        let decryptData = AESUtil.getAES128Decrypt(encoded: response.toBase64()).bytes
        
        if decryptData[0] == 0x21 && horn_push {
            if decryptData[1] == 0x01 { //success
                print("성공")
            }
            else{ //fail
                print("실패")
            }
            horn_push = false
            
        } else if decryptData[0] == 0x22 && open_push {
            if decryptData[1] == 0x01 { //success
                print("성공")
            } else { //fail
                print("실패")
            }
            
        } else if decryptData[0] == 0x23 && close_push {
            if decryptData[1] == 0x01 { //success
                print("성공")
            }else{ //fail
                print("실패")
            }
            close_push = false
        } else if decryptData[0] == 0x24 { //master init
            if decryptData[1] == 0x01 && decryptData[2] == 0x0F {
                print("마스터 등록해제를 완료했습니다.")
            } else if decryptData[1] == 0x02 && decryptData[2] == 0x0F {
                print("마스터 등록해제를 실패하였습니다.")
            }
        }
    }
    
    
    /*
     Alert 함수
     */
    func disconnectedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("disconnect", comment: ""), message: NSLocalizedString("connect disconnect msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
