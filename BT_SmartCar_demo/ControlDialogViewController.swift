
import UIKit

class ControlDialogViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var jogText: UILabel!
    @IBOutlet weak var sparrowImg: UIImageView!
    @IBOutlet weak var dialText: UILabel!
    
    let bg_img = UIImage(named: "ico_msg_bg")
    let bg_back_img = UIImage(named: "ico_msg_bg_back")
    let bg_home_img = UIImage(named: "ico_msg_bg_home")
    let bg_navi_img = UIImage(named: "ico_msg_bg_navi")
    
    var text: String!
    var msg: String!
    var img: bgImg?
    var directionImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4){
            LoadingSerivce.hideLoading()
        }
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadingSerivce.hideLoading()

        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        if let bgimg = img?.image {
            imageView.image = bgimg
        }
        
        if let dimg = directionImage {
            sparrowImg.image = dimg
        }
        
        dialText.text = msg
        jogText.text = text
        
    }
}
