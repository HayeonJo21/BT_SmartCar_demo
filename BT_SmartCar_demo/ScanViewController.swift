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
        
        serial.delegate = self
        serial.startScan()
        
        scanListTableView.delegate = self
        scanListTableView.dataSource = self
        
    }
    
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        for existing in peripheralList {
            if existing.peripheral.identifier == peripheral.identifier { return }
        }
        
        let fRSSI = RSSI?.floatValue ?? 0.0
        peripheralList.append((peripheral: peripheral, RSSI: fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI }
        scanListTableView.reloadData()
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
