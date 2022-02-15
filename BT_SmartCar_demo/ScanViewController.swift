//
//  ScanViewController.swift
//  BT_SmartCar_demo
//
//  Created by Hayeon at Norma on 2022/02/15.
//

import UIKit

class ScanViewController: UIViewController {

    @IBOutlet weak var scanListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanListTableView.delegate = self
        scanListTableView.dataSource = self
        

    }
}
    extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
                
                return cell
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
            
            return cell
         
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.row == 0 {
                return UITableView.automaticDimension
            }
            
            return 60
            
        }

    }
