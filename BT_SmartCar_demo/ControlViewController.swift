import UIKit
import CoreBluetooth

class ControlViewController: UIViewController {

    var connectedPeripheral: CBPeripheral!
    var start: Bool = false
    let AESUtil = AES128Util()
    
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
    
    //암호화해서 데이터를 보냄
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
        
        sendRequestData(cmd: cmd, data: data)
    }
    
    @IBAction func doorClose(_ sender: Any) {
        let cmd = CConfig().REQUEST_DOOR_CLOSE_CMD
        let data = CConfig().REQUEST_DOOR_CLOSE
        
        sendRequestData(cmd: cmd, data: data)
        
    }
    
    @IBAction func carHorn(_ sender: Any) {
        
    }
    
    @IBAction func disconnect(_ sender: Any) {
        
    }
    
    @IBAction func masterDelete(_ sender: Any) {
        
        let cmd = CConfig().REQUEST_MASTER_INIT_CMD
        let data = CConfig().REQUEST_MASTER_INIT
        
        sendRequestData(cmd: cmd, data: data)
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
