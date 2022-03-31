import UIKit
import AnyFormatKit

class PhoneNumberModalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func okButton(_ sender: Any) {
        
    }
    
}
extension ViewController: UITextFieldDelegate {
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
        
        return false
    }
}
