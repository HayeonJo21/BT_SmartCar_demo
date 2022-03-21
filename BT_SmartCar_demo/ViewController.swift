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
        //        definesPresentationContext = true
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.title = "Intro"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //권한 확인을 위한 메소드
    func checkAuthorization(){
        //TODO: 권한확인(핸드폰번호, 맥주소 등등으로 권한확인) 후 ScanViewController로 자동이동
    }
    
    @IBAction func btScanBtn(_ sender: Any) {
        let scanListVC = ScanViewController(nibName: "ScanViewController", bundle: nil)
        
        self.navigationController?.pushViewController(scanListVC, animated: true)
        
    }
    @IBAction func exitAction(_ sender: Any) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        
        DispatchQueue.main.asyncAfter(deadline:  .now()) {
            exit(0)
        }
    }
}


