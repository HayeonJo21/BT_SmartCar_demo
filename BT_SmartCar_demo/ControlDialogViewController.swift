
import UIKit

class ControlDialogViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let bg_img = UIImage(named: "ico_msg_bg.png")
    let bg_back_img = UIImage(named: "ico_msg_bg_back.png")
    let bg_home_img = UIImage(named: "ico_msg_bg_home.png")
    let bg_navi_img = UIImage(named: "ico_msg_bg_navi.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        imageView.image = bg_back_img
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
    }
}
