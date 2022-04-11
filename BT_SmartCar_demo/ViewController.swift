import UIKit
import CoreBluetooth
import TAKUUID
import CoreData

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        definesPresentationContext = true
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.title = "Home"
        
        // mac address 대신 uuid keychain 생성
        TAKUUIDStorage.sharedInstance().migrate()
        if let mac = TAKUUIDStorage.sharedInstance().findOrCreate() {
            phoneMacAddr = mac
        } else {
            return
        }
        
        print("uuid keychain: " + phoneMacAddr)
        
        phoneMacAddr = sliceMacAddress(mac: phoneMacAddr)
        
        print("Sliced Mac Address \(phoneMacAddr)")
        
        fetchData()
        var currentUser: Users!
        
        if users.isEmpty {
            let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
            phoneNumVC.modalPresentationStyle = .formSheet
            self.present(phoneNumVC, animated: true)
        }
        else {
            for user in users {
                print("for문 내부")
                if user.phoneMac == phoneMacAddr{
                    currentUser = user
                    break
                }
            }
            
            if currentUser.phoneNum == "" {
                let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
                phoneNumVC.modalPresentationStyle = .formSheet
                self.present(phoneNumVC, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //권한 확인을 위한 메소드
    func checkAuthorization(){
        var currentUser: Users!
        
        fetchData()
        
        if users.isEmpty {
            let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
            phoneNumVC.modalPresentationStyle = .formSheet
            self.present(phoneNumVC, animated: true)
        }
        else {
            for user in users {
                print("for문 내부2")
                if user.phoneMac == phoneMacAddr{
                    currentUser = user
                    break
                }
            }
            if currentUser.phoneNum == "" {
                emptyPhoneNumberAlert()
            }
        }
        
    }
    
    //mac address 자르기
    func sliceMacAddress(mac: String) -> String{
        let startIndex = mac.index(mac.startIndex, offsetBy: 24)
        let endIndex = mac.index(mac.startIndex, offsetBy: 35)
        
        let sliced_mac = mac[startIndex ..< endIndex]
        
        return String(sliced_mac)
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
    
    func emptyPhoneNumberAlert(){
        let alert = UIAlertController(title: NSLocalizedString("empty phoneNumber", comment: ""), message: NSLocalizedString("empty phoneNumber msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
            phoneNumVC.modalPresentationStyle = .formSheet
            self.present(phoneNumVC, animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func saveUser(){
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Users", in: context) else {
            return
        }
        
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? Users else { return }
        
        object.phoneNum = phoneNumber
        object.phoneMac = phoneMacAddr
        object.uuid = UUID()
        
        appdelegate.saveContext()
        print("[COREDATA] Users: " + phoneNumber + "//" + phoneMacAddr + " 저장됨.")
    }
    
    //local data 가져옴
    func fetchData(){
        print("[COREDATA] fetchData")
        let fetchRequest: NSFetchRequest<Users> = Users.fetchRequest()
        
        let context = appdelegate.persistentContainer.viewContext
        
        do{
            self.users = try context.fetch(fetchRequest)
            
        }catch{
            print(error)
        }
        
    }
}


