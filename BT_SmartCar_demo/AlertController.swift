import Foundation
import UIKit

class AlertController {

func sendEmailAlert(){
    let alert = UIAlertController(title: NSLocalizedString("sending email", comment: ""), message: NSLocalizedString("sending email msg", comment: ""), preferredStyle: .actionSheet)
    
    let buttonAction = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(buttonAction)
    self.present(alert, animated: true, completion: nil)
    
}

func emptyNumberAlert(){
    let alert = UIAlertController(title: "입력 오류", message: "인증번호 6자리를 입력해주세요.", preferredStyle: .actionSheet)
    
    let buttonAction = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(buttonAction)
    self.present(alert, animated: true, completion: nil)
    
}

func wrongNumberAlert(){
    let alert = UIAlertController(title: "입력 오류", message: "인증번호가 틀렸습니다.", preferredStyle: .actionSheet)
    
    let buttonAction = UIAlertAction(title: "확인", style: .default, handler: nil)
    
    alert.addAction(buttonAction)
    self.present(alert, animated: true, completion: nil)
    
}

func threeTimeWrongNumberAlert(){
    let alert = UIAlertController(title: "입력 오류", message: "인증번호를 3회 틀렸습니다. 처음단계로 돌아갑니다.", preferredStyle: .actionSheet)
    
    let buttonAction = UIAlertAction(title: "확인", style: .default, handler: { _ in self.navigationController?.popViewController(animated: true)})
    
    alert.addAction(buttonAction)
    self.present(alert, animated: true, completion: nil)
    
}
}
