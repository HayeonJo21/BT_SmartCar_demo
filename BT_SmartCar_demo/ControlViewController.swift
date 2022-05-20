import UIKit
import CoreBluetooth

enum bgImg: Int64 {
    case back
    case home
    case navi
}

extension bgImg {
    var image: UIImage {
        switch self{
        case .back:
            return UIImage(named: "ico_msg_bg_back.png")!
        case .home:
            return UIImage(named: "ico_msg_bg_home.png")!
        case .navi:
            return UIImage(named: "ico_msg_bg_navi.png")!
        }
    }
}

var controllerFlag = 0
class ControlViewController: UIViewController {
    
    var connectedPeripheral: CBPeripheral!
    var start: Bool = false
    let AESUtil = AES128Util()
    var resultData: [UInt8] = Array(repeating: 0x00, count: 16)
    var devUser = 0
    
    @IBOutlet weak var masterDelete: UIView!
    @IBOutlet weak var masterDeleteIMG: UIImageView!
    @IBOutlet weak var masterDeleteBtn: UIButton!
    
    //status flags
    var horn_push = false
    var open_push = false
    var close_push = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
       
        DispatchQueue.main.async {
            LoadingSerivce.hideLoading()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.decryptDataAndAction), name: .broadcaster_2, object: nil)
        
        if devUser != 1 {
            masterDelete.isHidden = true
            masterDeleteBtn.isHidden = true
            masterDeleteIMG.isHidden = true
        }
    }
    
    //암호화해서 데이터를 보내는 함수
    func sendRequestData(cmd: [UInt8], data: [UInt8]){
        
        let encryptData = AESUtil.setAES128Encrypt(bytes: data)
        
        let sendDataByte = cmd + encryptData
        
        print(">>>> [Control] data 전송: \(sendDataByte.toHexString())")
        
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
        
        controllerFlag = 1
        
        self.dismiss(animated: true)
//        guard let pvc = presentingViewController as? UINavigationController else { return }
//
//
//        self.dismiss(animated: true){
//            print("[Control View Controller] Dismiss\n")
//            pvc.popToRootViewController(animated: true)
//        }
    }
    
    @IBAction func masterDelete(_ sender: Any) {
        
        let cmd = REQUEST_MASTER_INIT_CMD
        let data = REQUEST_MASTER_INIT
        
        sendRequestData(cmd: cmd, data: data)
    }
    
    @IBAction func masterDeleteTest(_ sender: Any) {
        
        let cmd = REQUEST_MASTER_INIT_CMD
        let data = REQUEST_MASTER_INIT
        
        sendRequestData(cmd: cmd, data: data)
        
    }
    
    
    // 응답을 받아 처리하는 부분
    @objc func decryptDataAndAction(){
        
        //연결 상태 확인
        if connectedPeripheral.state == .disconnected {
            print("연결되지 않은 상태")
            disconnectedAlert()
        }
        else if connectedPeripheral.state == .connected {
            print("연결된 상태")
            start = true
        }
        
        let cmd = parseHexCode(bytes: response)
        
        if response.endIndex > 2 {
            for i in resultData.startIndex..<resultData.endIndex {
                resultData[i] = response[i + 1]
            }
        }
        
        //복호화
        let decryptData = AES128Util().getAES128Decrypt(encoded: resultData)
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
                    print("마스터 등록해제를 완료했습니다.\n")
                } else if decryptData[1] == 0x02 && decryptData[2] == 0x0F {
                    print("마스터 등록해제를 실패하였습니다.\n")
                }
            }
        }else if cmd.caseInsensitiveCompare("A3") == ComparisonResult.orderedSame {
            
            if type.caseInsensitiveCompare("B1") == ComparisonResult.orderedSame {
                if decryptData[2] == 0x00 {
                    let alphabet = decryptData[1]
                    
                    if alphabet > 64 && alphabet < 91 {
                        print("대문자\n")
                    }else {
                        print("소문자\n")
                    }
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB1] + SUCCESS)
                }else{
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB1] + FAIL)
                }
            } else if type.caseInsensitiveCompare("B2") == ComparisonResult.orderedSame {
                if decryptData[2] == 0x00 {
                    print("표시된 내용을 입력해주세요.")
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB2] + SUCCESS)
                }else{
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB2] + FAIL)
                }
            } else if type.caseInsensitiveCompare("B3") == ComparisonResult.orderedSame {
                if decryptData[1] == 0x31 {
                    let value = parseHexCode(bytes: decryptData)
                    
                    if value.caseInsensitiveCompare("31") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㄱ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("32") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㄲ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("34") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㄴ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("37") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㄷ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("38") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㄸ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("39") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㄹ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("41") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅁ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("42") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅂ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("43") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅃ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("45") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅅ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("46") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅆ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("47") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅇ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("48") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅈ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("49") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅉ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("4A") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅊ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("4B") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅋ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("4C") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅌ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("4D") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅍ", text: MSG_INPUT)
                    } else if value.caseInsensitiveCompare("4E") == ComparisonResult.orderedSame {
                        jog_control(control: CONTROL_EMPTY, msg: "ㅎ", text: MSG_INPUT)
                    } else {
                        sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB3] + FAIL)
                    }
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB3] + SUCCESS)
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB3] + FAIL)
                    
                }
            } else if type.caseInsensitiveCompare("B4") == ComparisonResult.orderedSame {
                let turnCnt = decryptData[2].description
                
                if decryptData[1] == 0x01 {
                    jog_control(control: JOG_LEFT, msg: turnCnt, text: "왼쪽 방향으로 \(turnCnt)회 돌려주세요.")
                } else if decryptData[1] == 0x02 {
                    jog_control(control: JOG_RIGHT, msg: turnCnt, text: "오른쪽 방향으로 \(turnCnt)회 돌려주세요.")
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB4] + FAIL)
                    return
                }
                sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB4] + SUCCESS)
            } else if type.caseInsensitiveCompare("B5") == ComparisonResult.orderedSame {
                if decryptData[1] == 0x11 {
                    jog_control(control: GESTURE_LEFT, msg: "", text: "왼쪽 방향으로 움직여주세요.")
                } else if decryptData[1] == 0x12 {
                    jog_control(control: GESTURE_RIGHT, msg: "", text: "오른쪽 방향으로 움직여주세요.")
                } else if decryptData[1] == 0x13 {
                    jog_control(control: GESTURE_UP, msg: "", text: "위쪽 방향으로 움직여주세요.")
                } else if decryptData[1] == 0x14 {
                    jog_control(control: GESTURE_DOWN, msg: "", text: "아래쪽 방향으로 움직여주세요.")
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB5] + FAIL)
                    return
                }
                sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB5] + SUCCESS)
            } else if type.caseInsensitiveCompare("B6") == ComparisonResult.orderedSame
                        && decryptData[2] == 0x00 {
                let value = parseHexCode(bytes: decryptData)
                
                if value.caseInsensitiveCompare("A1") == ComparisonResult.orderedSame {
                    jog_control(control: BTN_BACK_TOUCH, msg: "", text: "BACK 버튼을 터치해주세요.")
                } else if value.caseInsensitiveCompare("A2") == ComparisonResult.orderedSame {
                    jog_control(control: BTN_BACK_PUSH, msg: "", text: "BACK 버튼을 세게 눌러주세요.")
                } else if value.caseInsensitiveCompare("A3") == ComparisonResult.orderedSame {
                    jog_control(control: BTN_HOME_TOUCH, msg: "", text: "HOME 버튼을 터치해주세요.")
                } else if value.caseInsensitiveCompare("A4") == ComparisonResult.orderedSame {
                    jog_control(control: BTN_HOME_PUSH, msg: "", text: "HOME 버튼을 세게 눌러주세요.")
                } else if value.caseInsensitiveCompare("A5") == ComparisonResult.orderedSame {
                    jog_control(control: BTN_NAVI_TOUCH, msg: "", text: "NAVI 버튼을 터치해주세요.")
                } else if value.caseInsensitiveCompare("A6") == ComparisonResult.orderedSame {
                    jog_control(control: BTN_NAVI_PUSH, msg: "", text: "NAVI 버튼을 세게 눌러주세요.")
                } else {
                    sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB6] + FAIL)
                    return
                }
                sendRequestData(cmd: RESPONSE_JOG_CMD, data: [0xB6] + SUCCESS)
            } else {
                print("ERROR 처리")
            }
        }
    }
    
    func jog_control(control:Int, msg: String, text: String){
        //timer = true
        
        let jogDialogVC = ControlDialogViewController.init(nibName: "ControlDialogViewController", bundle: nil)
        
        if control <= 2 {
            if control == JOG_LEFT {
                jogDialogVC.directionImage = UIImage(named: "dialspin2")
            } else if control == JOG_RIGHT {
                jogDialogVC.directionImage = UIImage(named: "dialspin1")
            }
        } else if control > 2 && control <= 6 {
            if control == GESTURE_LEFT {
                jogDialogVC.directionImage = UIImage(named: "icon_l_sparrow")
            }else if control == GESTURE_RIGHT {
                jogDialogVC.directionImage = UIImage(named: "icon_r_sparrow")

            }else if control == GESTURE_UP {
                jogDialogVC.directionImage = UIImage(named: "icon_u_sparrow")

            }else if control == GESTURE_DOWN {
                jogDialogVC.directionImage = UIImage(named: "icon_d_sparrow")

            }
        } else if control > 6 && control <= 12 {
            if control == BTN_BACK_TOUCH || control == BTN_BACK_PUSH {
                jogDialogVC.img = .back
                
            }else if control == BTN_HOME_TOUCH || control == BTN_HOME_PUSH {
                jogDialogVC.img = .home
                
            }else if control == BTN_NAVI_PUSH || control == BTN_NAVI_TOUCH {
                jogDialogVC.img = .navi
            }
        }
        //text 및 메시지 다 설정해서 controlDialogViewController로 보내기
        
        jogDialogVC.msg = msg
        jogDialogVC.text = text
        
        self.present(jogDialogVC, animated: true)
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
