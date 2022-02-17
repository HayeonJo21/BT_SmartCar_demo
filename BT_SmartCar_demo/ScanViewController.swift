//
//  ScanViewController.swift
//  BT_SmartCar_demo
//
//  Created by Hayeon at Norma on 2022/02/15.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController, BluetoothSerialDelegate {


    @IBOutlet weak var scanListTableView: UITableView!
    var peripheralList : [(peripheral: CBPeripheral, RSSI : Float)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralList = []
        
        scanListTableView.delegate = self
        scanListTableView.dataSource = self
        
        serial.delegate = self
        serial.startScan()
      
        
    }
    
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        print("프로토콜 함수 호출")
        for existing in peripheralList {
            if existing.peripheral.identifier == peripheral.identifier { return }
        }
        
        let fRSSI = RSSI?.floatValue ?? 0.0
        peripheralList.append((peripheral: peripheral, RSSI: fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI }
        scanListTableView.reloadData()
    }
    
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
        //        let connectSuccessAlert = UIAlertController(title: "블루투스 연결 성공", message: "기기와 성공적으로 연결됐습니다.", preferredStyle: .actionSheet)
        //
        //        let confirm = UIAlertAction(title: "확인", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
        //
        //        connectSuccessAlert.addAction(confirm)
        //        serial.delegate = nil
        //        present(connectSuccessAlert, animated: true, completion: nil)
        
        print("연결 성공!")
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
class func topViewController() -> UIViewController? {
    if let keyWindow = UIApplication.shared.keyWindow{
        // TODO
    }
}
