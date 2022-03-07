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
    var deviceModel: DeviceModel!
    var deviceList: [DeviceModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralList = []
        
        scanListTableView.delegate = self
        scanListTableView.dataSource = self
        
        scanListTableView.register(UINib(nibName: "ScanTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanTableViewCell")
        
        scanListTableView.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        self.title = "Device Scan List"
        
        serial.delegate = self
        self.startScan()
        
        
    }
    
    // 기기 검색을 시작할 함수
    func startScan(){
        print("=== 스캔 시작 ===")
        
        switch serial.manager.state {
        case .unknown:
            self.undefinedAlert()
        case .resetting:
           //블루투스 서비스 리셋
            break
        case .unsupported:
           //기기가 블루투스를 지원하지 않음
            break
        case .unauthorized:
            //블루투스 사용권한 확인 필요
            self.intentAppSettings(content: NSLocalizedString("authorization confirm msg", comment: "블루투스 권한 확인 메시지"))
        case .poweredOff:
           //블루투스 꺼짐 상태
            break
        case .poweredOn:
            //블루투스 활성상태
            serial.manager.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            //블루투스 케이스 디폴트
            break
        }
        
    }
    
    func undefinedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("bluetooth status alert", comment: ""), message: NSLocalizedString("back to home alert", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func intentAppSettings(content: String){
        let settingAlert = UIAlertController(title: NSLocalizedString("authotization alert", comment: ""), message: content, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            // 확인버튼 클릭 이벤트 내용 정의 실시
            if let url = URL(string: UIApplication.openSettingsURLString) {
                //앱 설정화면 이동
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
        let alert = UIAlertController(title: NSLocalizedString("stop scanning", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // 기기 검색때마다 호출
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        print("=== ScanViewController: 프로토콜 함수 호출 ===")
        
        deviceModel = DeviceModel()
        
        for item in peripheralList {
            if item.peripheral.identifier == peripheral.identifier {
                print(">> 중복 검사 <<")
                print(">> 중복된 디바이스 이름: " + (item.peripheral.name ?? "") + " <<")
                return
            }
        }
        
        // 이름이 없는 device 걸러내기
        if peripheral.name == nil || peripheral.name == "" {
            print(">> 이름이 없는 디바이스 걸러내기 <<")
            print("*** 이름 없는 디바이스 정보: " + peripheral.description + " ***")
            return
        }
        
        let fRSSI = RSSI?.floatValue ?? 0.0
        
        print("검색된 기기의 serviceUUID: " + peripheral.identifier.uuidString)
        let uuidString = peripheral.identifier.uuidString
        
        deviceModel.uuid = uuidString
        
        if let hasName = peripheral.name {
            deviceModel.name = hasName
        }else{
            return
        }
        
        deviceModel.risk = setRistOfDevice(device: deviceModel)
        
        deviceList.append(deviceModel)
        
        peripheralList.append((peripheral: peripheral, RSSI: fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI }
        
        scanListTableView.reloadData()
    }
    
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
        let connectSuccessAlert = UIAlertController(title: NSLocalizedString("connect succes", comment: ""), message: NSLocalizedString("connect success msg", comment: ""), preferredStyle: .actionSheet)
        
        let confirm = UIAlertAction(title: "확인", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
        
        connectSuccessAlert.addAction(confirm)
        serial.delegate = nil
        present(connectSuccessAlert, animated: true, completion: nil)
        
        print("연결 성공시 호출")
    }
    
    func setRistOfDevice(device: DeviceModel) -> Int {
        var risk: Int = 0
        
        //이름이 50자 이상이면 위험
        if device.name.count >= 50 {
            risk += 2
        }
        else if device.name.count >= 40 && device.name.count < 50 {
            risk += 1
        }
        
        return risk
    }

}
extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as? ScanTableViewCell else {
            return UITableViewCell()
        }
        
        let peripheralName = deviceList[indexPath.row].name
        
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
//이미 연결됐을 때 사용
//let peripherals = serial.manager.retrieveConnectedPeripherals(withServices: [uuid])
//for peripheral in peripherals {
//    serial.delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: NSNumber(value: fRSSI))
//    print("=== peripheral: " + peripheral.description + "===")
//}
