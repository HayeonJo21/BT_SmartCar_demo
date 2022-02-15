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
        let severityImageViewHeight : CGFloat = 55
        severityImageView.layer.cornerRadius = severityImageViewHeight / 2
        
        peripheralName.sizeToFit()
        
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
