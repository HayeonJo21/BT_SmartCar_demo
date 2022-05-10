import UIKit

class ResultDialogViewController: UIViewController {

    var sf: Bool!
    var msg: String!
    var user: Int!
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageOK = UIImage(named: "icon_ok.png")
        let imageIssue = UIImage(named: "icon_issue.png")
        
        if sf {
            resultImg.image = imageOK
        }else {
            resultImg.image = imageIssue
        }
        
        resultLabel.text = msg
        
        showing2 = true
        //NumberCertification result_showing -> true로
    }

    @IBAction func okButton(_ sender: Any) {
        showing2 = false
        
        if sf {
            
            if user < 3 {
                preferences.set("in", forKey: phoneMacAddr)
            }
            
            //정보 저장 후 control view로 이동
            
        } else {
            self.dismiss(animated: true)
            print("loginViewController finish\n")
        }
    }
    
}
