import UIKit
import AnyFormatKit

class PhoneNumberModalViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextFelid: UITextField!
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
            CConfig().phoneNumber = number
        } else{
            print("폰번호 입력되지 않음")
        }
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
