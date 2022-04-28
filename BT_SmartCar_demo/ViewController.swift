/*
 첫 화면
 
 sharedPreferences 정보
 - Mac주소 : userMac
 - Phone number : userPhoneNum
 - login 정보 : Mac 주소
 
 를 키로 저장함
 */

import UIKit
import CoreBluetooth
import TAKUUID

let preferences = UserDefaults.standard

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        definesPresentationContext = true
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.title = "Home"
        
        settingUserInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //mac address, phone number등 sharedPreference에 저장
    func settingUserInfo(){
        
        if preferences.object(forKey: "userMac") == nil {
            // mac address 대신 uuid keychain 생성
            TAKUUIDStorage.sharedInstance().migrate()
            if let mac = TAKUUIDStorage.sharedInstance().findOrCreate() {
                phoneMacAddr = mac
            } else {
                return
            }
            
            phoneMacAddr = sliceMacAddress(mac: phoneMacAddr)
            preferences.set(phoneMacAddr, forKey: "userMac")
        } else {
            print("[ViewController > settingUserInfo()] MAC Address 입력됨.")

        }
        
        //phone number
        if preferences.object(forKey: "userPhoneNum") == nil {
            
            let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
            phoneNumVC.modalPresentationStyle = .formSheet
            self.present(phoneNumVC, animated: true)
            
        } else{
            print("[ViewController > settingUserInfo()] Phone번호 입력됨.\n")
        }
        
        //login 정보
        if preferences.object(forKey: phoneMacAddr) == nil {
            preferences.set("out", forKey: phoneMacAddr)
        }
        
        let didSave = preferences.synchronize()
        
        
        if !didSave {
            emptySettingInfoAlert()
        }
        
    }
    
    func checkAuthorization(){
        if phoneNumber == "" || phoneMacAddr == "" {
            emptySettingInfoAlert()
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
                
        let scanListVC = ScanViewController(nibName: "ScanViewController", bundle: nil)
        
        self.navigationController?.pushViewController(scanListVC, animated: true)
        
    }
    
    @IBAction func exitAction(_ sender: Any) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        
        DispatchQueue.main.asyncAfter(deadline:  .now()) {
            exit(0)
        }
    }
    
    func emptySettingInfoAlert(){
        let alert = UIAlertController(title: NSLocalizedString("empty info", comment: ""), message: NSLocalizedString("empty info msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in
            let phoneNumVC = PhoneNumberModalViewController(nibName: "PhoneNumberModalViewController", bundle: nil)
            phoneNumVC.modalPresentationStyle = .formSheet
            self.present(phoneNumVC, animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
}
