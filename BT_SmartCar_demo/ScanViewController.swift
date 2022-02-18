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
        
        scanListTableView.backgroundColor = UIColor(white: 235/255, alpha: 1)
        
        serial.delegate = self
        serial.startScan()
      
        
    }
    @IBAction func stopScanning(_ sender: Any) {
       print("=== 스캔 중지 ===")
        serial.stopScan()
        self.dismiss(animated: true, completion: nil)
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
            
            cell.updatePeripheralsName(name: peripheralName)
            
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
