//
//  ViewController.swift
//  BT_SmartCar_demo
//
//  Created by Norma on 2022/02/09.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // BluetoothSerial.swift 파일에 있는 Bluetooth Serial인 serial을 초기화
        //        definesPresentationContext = true
        
        self.title = "Device Scan"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    @IBAction func btScanBtn(_ sender: Any) {
        let scanListVC = ScanViewController(nibName: "ScanViewController", bundle: nil)
        
        self.navigationController?.pushViewController(scanListVC, animated: true)
      
    }
    
}


