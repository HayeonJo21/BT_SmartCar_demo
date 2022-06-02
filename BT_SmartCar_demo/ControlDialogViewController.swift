
import UIKit

class ControlDialogViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var jogText: UILabel!
    @IBOutlet weak var sparrowImg: UIImageView!
    @IBOutlet weak var dialText: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    let bg_img = UIImage(named: "ico_msg_bg")
    let bg_back_img = UIImage(named: "ico_msg_bg_back")
    let bg_home_img = UIImage(named: "ico_msg_bg_home")
    let bg_navi_img = UIImage(named: "ico_msg_bg_navi")

    var text: String!
    var msg: String!
    var img: bgImg?
    var directionImage: UIImage?
    var timeSet: Int = 180 // 입력 제한시간 3분

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showingRemainTime()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
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
    
    //남은 시간 표시
    func showingRemainTime(){
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            self.timeSet -= 1
            
            let min = self.timeSet / 60
            let sec = self.timeSet % 60
            
            if self.timeSet > 0 {
                self.timeLabel.text = "⏰ \(min)분 \(sec)초 남음"
            }else{
                self.timeLabel.text = "인증 시간 만료"
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
