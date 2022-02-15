//
//  ViewController.swift
//  BT_SmartCar_demo
//
//  Created by Norma on 2022/02/09.
//

import UIKit

class ViewController: UIViewController, BluetoothSerialDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // BluetoothSerial.swift 파일에 있는 Bluetooth Serial인 serial을 초기화
        serial = BluetoothSerial.init()
    }

    @IBAction func btScanBtn(_ sender: Any) {
        //segue 호출하여 scanView 로드
        performSegue(withIdentifier: "ScanViewController", sender: nil)
    }
    
}

