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
    }
    
    @IBAction func btScanBtn(_ sender: Any) {
        let scanListVC = ScanViewController(nibName: "ScanViewController", bundle: nil)
        
        self.present(scanListVC, animated: true, completion: nil)
      
    }
    
}


