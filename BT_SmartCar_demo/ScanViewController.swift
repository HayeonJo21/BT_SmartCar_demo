//
//  ScanViewController.swift
//  BT_SmartCar_demo
//
//  Created by Hayeon at Norma on 2022/02/15.
//

import UIKit
import CoreBluetooth

var serial: BluetoothSerial! = BluetoothSerial.init()

class ScanViewController: UIViewController, BluetoothSerialDelegate {

    
    @IBOutlet weak var scanListTableView: UITableView!
    var peripheralList : [(peripheral: CBPeripheral, RSSI : Float)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralList = []
        
        scanListTableView.delegate = self
        scanListTableView.dataSource = self
        
        scanListTableView.register(UINib(nibName: "ScanTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanTableViewCell")
        
        scanListTableView.backgroundColor = UIColor(white: 250/255, alpha: 1)
        
        serial.delegate = self
        self.startScan()
        
        
    }
    
    // 기기 검색을 시작할 함수
    func startScan(){
        print("=== 스캔 시작 ===")
        
        switch serial.manager.state {
        case .unknown:
            print(">> 블루투스 상태 알 수 없음 << ")
            self.undefinedAlert()
        case .resetting:
            print(">> 블루투스 서비스 리셋 <<")
        case .unsupported:
            print(">> 기기가 블루투스를 지원하지 않음 <<")
        case .unauthorized:
            print(">> 블루투스 사용 권한 확인 필요 <<")
            self.intentAppSettings(content: "블루투스 사용 권한을 허용해주세요.")
        case .poweredOff:
            print(">> 블루투스 비활성화 상태 <<")
        case .poweredOn:
            print(">> 블루투스 활성 상태 <<")
            serial.manager.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print(">> 블루투스 케이스 디폴트 <<")
        }
        
        //        let peripherals = manager.retrieveConnectedPeripherals(withServices: nil)
        //
        //        for peripheral in peripherals {
        //            delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
        //            print("=== peripheral: " + peripheral.description + "===")
        //        }
        //
    }
    
    func undefinedAlert(){
        let alert = UIAlertController(title: "블루투스 상태 알람", message: "블루투스의 상태를 알 수 없습니다. 초기 화면으로 돌아갑니다.", preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
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
        self.present(settingAlert, animated: true, completion: nil)

        
        //        let noAction = UIAlertAction(title: "취소", style: .default){ (action) in return}
        
        //        settingAlert.addAction(noAction)
        //        present(settingAlert, animated: true, completion: nil)
    }

    @IBAction func stopScanning(_ sender: Any) {
       print("=== 스캔 중지 ===")
        serial.stopScan()
        stopAlert()
    }
    
    func stopAlert(){
        let alert = UIAlertController(title: "블루투스 스캔을 중지하고 처음으로 돌아갑니다.", message: nil, preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        print("=== ScanViewController: 프로토콜 함수 호출 ===")
        for existing in peripheralList {
            if existing.peripheral.identifier == peripheral.identifier {
                print(">> 중복 검사 <<")
                return
            }
        }
        
        let fRSSI = RSSI?.floatValue ?? 0.0
        print("검색된 기기: " + peripheral.description)
        peripheralList.append((peripheral: peripheral, RSSI: fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI }
        scanListTableView.reloadData()
    }
    
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
                let connectSuccessAlert = UIAlertController(title: "블루투스 연결 성공", message: "기기와 성공적으로 연결됐습니다.", preferredStyle: .actionSheet)
        
                let confirm = UIAlertAction(title: "확인", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
        
                connectSuccessAlert.addAction(confirm)
                serial.delegate = nil
                present(connectSuccessAlert, animated: true, completion: nil)
        
        print("연결 성공시 호출")
    }
   

    
}
    extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return peripheralList.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as? ScanTableViewCell else {
                return UITableViewCell()
            }
            
            let peripheralName = peripheralList[indexPath.row].peripheral.name
            
            if peripheralName != "(null)"{
            cell.updatePeripheralsName(name: peripheralName)
            }
            
            return cell
         
        }
    }
//
//    func checkBTPermission(){
//        print("=== 블루투스 사용 권한 요청 실시 ===")
//    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("블루투스 스캔 NAME: \(String(peripheral.name ?? "null"))")
    }
//class func topViewController() -> UIViewController? {
//    if let keyWindow = UIApplication.shared.keyWindow{
//        // TODO
//    }
//}
