//
//  ViewController.swift
//  BT_SmartCar_demo
//
//  Created by Norma on 2022/02/09.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, BluetoothSerialDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // BluetoothSerial.swift 파일에 있는 Bluetooth Serial인 serial을 초기화
        serial = BluetoothSerial.init()
    }
    
    func checkBTPermission(){
        print("=== 블루투스 사용 권한 요청 실시 ===")
        serial.centralManager = CBCentralManager(delegate: serial, queue: nil)
    }
    
    func intentAppSettings(content: String){
        let settingAlert = UIAlertController(title: "권한 설정 알람", message: content, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            // 확인버튼 클릭 이벤트 내용 정의 실시
            if let url = URL(string: UIApplication.openSettingsURLString) {
                print("앱 설정 화면 이동")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        settingAlert.addAction(okAction)
        
        let noAction = UIAlertAction(title: "취소", style: .default){ (action) in return}
        
        settingAlert.addAction(noAction)
        present(settingAlert, animated: true, completion: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("블루투스 상태 알 수 없음")
        case .resetting:
            print("블루투스 서비스 리셋")
        case .unsupported:
            print("기기가 블루투스를 지원하지 않음")
        case .unauthorized:
            print("블루투스 사용 권한 확인 필요")
            self.intentAppSettings(content: "블루투스 사용 권한을 허용해주세요.")
        case .poweredOff:
            print("블루투스 비활성화 상태")
        case .poweredOn:
            print("블루투스 활성 상태")
        @unknown default:
            print("블루투스 케이스 디폴트")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("블루투스 스캔 NAME: \(String(peripheral.name ?? "null"))")
    }


    @IBAction func btScanBtn(_ sender: Any) {
        checkBTPermission()
        //segue 호출하여 scanView 로드
        performSegue(withIdentifier: "ScanViewController", sender: nil)
    }
    
}


