import Foundation
import SwiftSMTP

let email = master_email
let pwd = master_pwd
let title = email_title
let codeChar = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
var user_email: String!
var certificateMsg: String?
var certiNumber: String?

let smtp = SMTP(hostname: "smtp.gmail.com", email: email, password: pwd)
let mail_from = Mail.User(name: "BTSmartCar 인증", email: email)
let mail_to = Mail.User(name: "mail_to", email: user_email)

//이메일 인증 코드 생성
func createEmailCode() -> String{
    var certiCode: String = ""

    for _ in 0...5 {
        let randNum = Int.random(in: 1 ... (codeChar.count - 1))
        certiCode +=  codeChar[randNum]
    }
    return certiCode
}

func generateEmailContent() -> String {
    var result = ""
    
    if certificateMsg != nil {
        result += "Certification Number \n\n" + "[ " + certificateMsg! + " ]\n" + "Add User: (추가 사용자 인증번호), Temp User: (임시 사용자 인증번호) \n\n APP에서 인증번호를 입력해주세요."
    } else if certiNumber != nil{
        result += "Certification Number \n \n" + "[ " + certiNumber! + " ] \n APP에서 인증번호를 입력해주세요."
    }
    
    return result
}

let content = generateEmailContent()

let mail = Mail(from: mail_from, to: [mail_to], subject: title, text: content)
