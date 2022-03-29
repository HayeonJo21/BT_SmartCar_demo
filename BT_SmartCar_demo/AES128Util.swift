import Foundation
import CryptoSwift

class AES128Util {
    private let SECRET_KEY = "0123456789abcdef" //16 bytes
    private let IV = "" // IV지정
    
    func getAES128Object() -> AES { //설정 값 지정
        let keyDecodes: [UInt8] = SECRET_KEY.bytes
        var ivDecodes: [UInt8] = []
        
        if IV != "" || self.IV.count > 0 {
            ivDecodes = IV.bytes
        }else{
            ivDecodes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        }
        
        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs7)
        
        return aesObject
    }
    
    //암호화
    func setAES128Encrypt(string: String) -> String {
        guard !string.isEmpty else { return "" }
        return try! self.getAES128Object().encrypt(string.bytes).toBase64()
    }
    
    //복호화
    func getAES128Decrypt(encoded: String) -> String {
        let datas = Data(base64Encoded: encoded)
        guard datas != nil else { return "" }
    
        let bytes = datas!.bytes
        let decode = try! self.getAES128Object().decrypt(bytes)
        
        return String(bytes: decode, encoding: .utf8) ?? ""
    }
}