import UIKit
import AnyFormatKit
import CoreData

class PhoneNumberModalViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appdelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var phoneNumberTextFelid: UITextField!
    @IBOutlet var uiView: UIView!
    @IBOutlet weak var okButton: UIButton! {
        didSet {
            okButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTextFelid.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
    }
    
    @IBAction func okButton(_ sender: Any) {
        if let number = phoneNumberTextFelid.text {
            phoneNumber = number
            print("입력된 폰번호: \(number)")
            phoneNumber = slicePhoneNumber(phoneNum: number)
            print("가공한 폰번호: \(phoneNumber)")
        } else{
            print("폰번호 입력되지 않음")
        }
        
        saveUser()
        self.dismiss(animated: true)
    }
    
    func slicePhoneNumber(phoneNum: String) -> String{
        let startIndex1 = phoneNum.index(phoneNum.startIndex, offsetBy: 4)
        let endIndex1 = phoneNum.index(phoneNum.startIndex, offsetBy: 8)
        
        let startIndex2 = phoneNum.index(phoneNum.startIndex, offsetBy: 9)
        let endIndex2 = phoneNum.index(phoneNum.startIndex, offsetBy: 13)
        
        let sliced1 = phoneNum[startIndex1 ..< endIndex1]
        let sliced2 = phoneNum[startIndex2 ..< endIndex2]
        
        let sliced_phoneNumber = sliced1 + sliced2
   
        return String(sliced_phoneNumber)
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
    
    
}
extension PhoneNumberModalViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        let characterSet = CharacterSet(charactersIn: string)
        if CharacterSet.decimalDigits.isSuperset(of: characterSet) == false {
            return false
        }
        
        let formatter = DefaultTextInputFormatter(textPattern: "###-####-####")
        let result = formatter.formatInput(currentText: text, range: range, replacementString: string)
        
        textField.text = result.formattedText
        
        let position = textField.position(from: textField.beginningOfDocument, offset: result.caretBeginOffset)!
        
        textField.selectedTextRange = textField.textRange(from: position, to: position)
        
        okButton.isEnabled = true
        
        return false
    }
}
