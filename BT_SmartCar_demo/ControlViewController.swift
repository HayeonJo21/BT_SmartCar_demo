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
        let cmd = REQUEST_DOOR_OPEN_CMD
        let data = REQUEST_DOOR_OPEN
        
        open_push = true
        sendRequestData(cmd: cmd, data: data)
    }
    
    @IBAction func doorClose(_ sender: Any) {
        let cmd = REQUEST_DOOR_CLOSE_CMD
        let data = REQUEST_DOOR_CLOSE
        
        close_push = true
        sendRequestData(cmd: cmd, data: data)
        
    }
    
    @IBAction func carHorn(_ sender: Any) {
        let cmd = REQUEST_PANIC_CMD
        let data = REQUEST_PANIC
        
        horn_push = true
        sendRequestData(cmd: cmd, data: data)
    }
    
    @IBAction func disconnect(_ sender: Any) {
        serial.manager.cancelPeripheralConnection(connectedPeripheral)
    }
    
    @IBAction func masterDelete(_ sender: Any) {
        
        let cmd = REQUEST_MASTER_INIT_CMD
        let data = REQUEST_MASTER_INIT
        
        sendRequestData(cmd: cmd, data: data)
    }
    
    
    // 응답을 받아 처리하는 부분
    func decryptDataAndAction(response: [UInt8]){
        let decryptData = AESUtil.getAES128Decrypt(encoded: response.toBase64()).bytes
        let cmd = parseCMDCode(bytes: response)
        let type = parseCMDCode(bytes: decryptData)
        
        if cmd.caseInsensitiveCompare("A4") == ComparisonResult.orderedSame {
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
        }else if cmd.caseInsensitiveCompare("A3") == ComparisonResult.orderedSame {
            if type.caseInsensitiveCompare("B1") == ComparisonResult.orderedSame {
                if decryptData[2] == 0x00 {
                    let alphabet = decryptData[1]
                    
                    if alphabet > 64 && alphabet < 91 {
                        print("대문자")
                    }else {
                        print("소문자")
                    }
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB1" + SUCCESS)
                }else{
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB1" + FAIL)
                }
            } else if type.caseInsensitiveCompare("B2") == ComparisonResult.orderedSame {
                if decryptData[2] == 0x00 {
                    print("표시된 내용을 입력해주세요.")
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB2" + SUCCESS)
                }else{
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB2" + FAIL)
                }
            } else if type.caseInsensitiveCompare("B3") == ComparisonResult.orderedSame {
                if decryptData[1] == 0x31 {
                    let value = parseHexCode(bytes: decryptData, cnt: 2)
                    
                    if value.caseInsensitiveCompare("31") == ComparisonResult.orderedSame {
                        print("ㄱ")
                    } else if value.caseInsensitiveCompare("32") == ComparisonResult.orderedSame {
                        print("ㄲ")
                    } else if value.caseInsensitiveCompare("34") == ComparisonResult.orderedSame {
                        print("ㄴ")
                    } else if value.caseInsensitiveCompare("37") == ComparisonResult.orderedSame {
                        print("ㄷ")
                    } else if value.caseInsensitiveCompare("38") == ComparisonResult.orderedSame {
                        print("ㄸ")
                    } else if value.caseInsensitiveCompare("39") == ComparisonResult.orderedSame {
                        print("ㄹ")
                    } else if value.caseInsensitiveCompare("41") == ComparisonResult.orderedSame {
                        print("ㅁ")
                    } else if value.caseInsensitiveCompare("42") == ComparisonResult.orderedSame {
                        print("ㅂ")
                    } else if value.caseInsensitiveCompare("43") == ComparisonResult.orderedSame {
                        print("ㅃ")
                    } else if value.caseInsensitiveCompare("45") == ComparisonResult.orderedSame {
                        print("ㅅ")
                    } else if value.caseInsensitiveCompare("46") == ComparisonResult.orderedSame {
                        print("ㅆ")
                    } else if value.caseInsensitiveCompare("47") == ComparisonResult.orderedSame {
                        print("ㅇ")
                    } else if value.caseInsensitiveCompare("48") == ComparisonResult.orderedSame {
                        print("ㅈ")
                    } else if value.caseInsensitiveCompare("49") == ComparisonResult.orderedSame {
                        print("ㅉ")
                    } else if value.caseInsensitiveCompare("4A") == ComparisonResult.orderedSame {
                        print("ㅊ")
                    } else if value.caseInsensitiveCompare("4B") == ComparisonResult.orderedSame {
                        print("ㅋ")
                    } else if value.caseInsensitiveCompare("4C") == ComparisonResult.orderedSame {
                        print("ㅌ")
                    } else if value.caseInsensitiveCompare("4D") == ComparisonResult.orderedSame {
                        print("ㅍ")
                    } else if value.caseInsensitiveCompare("4E") == ComparisonResult.orderedSame {
                        print("ㅎ")
                    } else {
                        sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB3" + FAIL)
                    }
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB3" + SUCCESS)
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB3" + FAIL)
                    
                }
            } else if type.caseInsensitiveCompare("B4") == ComparisonResult.orderedSame {
                let turnCnt = decryptData[2].description
                
                if decryptData[1] == 0x01 {
                    print("왼쪽 방향으로 \(turnCnt)회 돌려주세요.")
                } else if decryptData[1] == 0x02 {
                    print("오른쪽 방향으로 \(turnCnt)회 돌려주세요.")
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB4" + FAIL)
                    return
                }
                sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB4" + SUCCESS)
            } else if type.caseInsensitiveCompare("B5") == ComparisonResult.orderedSame {
                if decryptData[1] == 0x11 {
                    print("왼쪽 방향으로 움직여주세요.")
                } else if decryptData[1] == 0x12 {
                    print("오른쪽 방향으로 움직여주세요.")
                } else if decryptData[1] == 0x13 {
                    print("위쪽 방향으로 움직여주세요.")
                } else if decryptData[1] == 0x14 {
                    print("아래쪽 방향으로 움직여주세요.")
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB5" + FAIL)
                    return
                }
                sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB5" + SUCCESS)
            } else if type.caseInsensitiveCompare("B6") == ComparisonResult.orderedSame
                        && decryptData[2] == 0x00 {
                let value = parseHexCode(bytes: decryptData, cnt: 1)
                
                if value.caseInsensitiveCompare("A1") == ComparisonResult.orderedSame {
                    print("BACK 버튼을 터치해주세요.")
                } else if value.caseInsensitiveCompare("A2") == ComparisonResult.orderedSame {
                    print("BACK 버튼을 세게 눌러주세요.")
                } else if value.caseInsensitiveCompare("A3") == ComparisonResult.orderedSame {
                    print("HOME 버튼을 터치해주세요.")
                } else if value.caseInsensitiveCompare("A4") == ComparisonResult.orderedSame {
                    print("HOME 버튼을 세게 눌러주세요.")
                } else if value.caseInsensitiveCompare("A5") == ComparisonResult.orderedSame {
                    print("NAVI 버튼을 터치해주세요.")
                } else if value.caseInsensitiveCompare("A6") == ComparisonResult.orderedSame {
                    print("NAVI 버튼을 세게 눌러주세요.")
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB6" + FAIL)
                    return
                }
                
                sendRequestData(cmd: RESPONSE_JOG_CMD, data: "0xB6" + SUCCESS)
            } else {
                print("ERROR 처리")
            }
        }
    }
        
    //command 패킷 가져오는 함수
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
    func disconnectedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("disconnect", comment: ""), message: NSLocalizedString("connect disconnect msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
