import UIKit
import CoreBluetooth
import TAKUUID

var myMac: String!

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        definesPresentationContext = true
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.title = "Home"
        
        let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
        
        self.present(phoneNumVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //권한 확인을 위한 메소드
    func checkAuthorization(){
        //TODO: 권한확인(핸드폰번호, Mac address 등으로 권한 확인) 후 ScanViewController로 자동이동
        if phoneNumber != "" {
            print("핸드폰 번호 입력됨: " + (phoneNumber ?? "empty"))
        }
        
        TAKUUIDStorage.sharedInstance().migrate()
        myMac = TAKUUIDStorage.sharedInstance().findOrCreate()
        
    }
    
    @IBAction func btScanBtn(_ sender: Any) {
        checkAuthorization()
        
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


