//
//  ScanTableViewCell.swift
//  BT_SmartCar_demo
//
//  Created by Norma on 2022/02/15.
//

import UIKit

class ScanTableViewCell: UITableViewCell {

    @IBOutlet weak var peripheralName: UILabel!
    @IBOutlet weak var severityImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("=== TableCellController: 셀 어웨이크 함수 called ===")
        let severityHeight : CGFloat = 34
        severityImageView.layer.cornerRadius = severityHeight / 2
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        
        peripheralName.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updatePeripheralsName(name : String?)
    {
        guard name != nil else { return }
        peripheralName.text = name
    }
    
}
