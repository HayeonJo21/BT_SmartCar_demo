
import UIKit

class ControlDialogViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var jogText: UILabel!
    @IBOutlet weak var sparrowImg: UIImageView!
    @IBOutlet weak var dialText: UILabel!
    
    let bg_img = UIImage(named: "ico_msg_bg.png")
    let bg_back_img = UIImage(named: "ico_msg_bg_back.png")
    let bg_home_img = UIImage(named: "ico_msg_bg_home.png")
    let bg_navi_img = UIImage(named: "ico_msg_bg_navi.png")
    
    var text: String!
    var msg: String!
    var img: bgImg!
    var directionImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        imageView.image = img.image
        sparrowImg.image = directionImage
        
        dialText.text = msg
        jogText.text = text
    }
}
