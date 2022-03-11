//
//  LoginViewController.swift
//  BT_SmartCar_demo
//
//  Created by Norma on 2022/03/11.
//

import UIKit

class LoginViewController: UIViewController {
    
    var device: DeviceModel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var titleText: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        deviceNameLabel.text = device.name

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "BluetoothLE Smart Car Service"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        titleText.textColor = .white
        deviceNameLabel.textColor = .white
        
    }


}
