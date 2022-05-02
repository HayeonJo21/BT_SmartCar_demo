import Foundation
import CryptoSwift

var CIPHER_KEY: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var TEMP_KEY: [UInt8]!

class AES128Util {
    private var SECRET_KEY = CIPHER_KEY //16 bytes
    private let IV = "" // IV지정
    
    func getAES128Object() -> AES { //설정 값 지정
        let keyDecodes: [UInt8] = CIPHER_KEY
        
        print(">>> KeyDecodes(키값): \(CIPHER_KEY.debugDescription)")

        var ivDecodes: [UInt8] = []
        
        if IV != "" || self.IV.count > 0 {
            ivDecodes = IV.bytes
        }else{
            ivDecodes = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        }
        
        let aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .noPadding)
        
        return aesObject
    }
    
    //암호화(string)
    func setAES128EncryptString(string: String) -> String {
        guard !string.isEmpty else { return "" }
        return try! self.getAES128Object().encrypt(string.bytes).toBase64()
    }
    
    //암호화(bytes)
    func setAES128Encrypt(bytes: [UInt8]) -> [UInt8] {
        return try! self.getAES128Object().encrypt(bytes)
    }
    
    //복호화
    func getAES128DecryptString(encoded: String) -> String {
        let datas = Data(base64Encoded: encoded)
        guard datas != nil else { return "" }
    
        let bytes = datas!.bytes
//        let decode = Data(try! self.getAES128Object().decrypt(bytes))
        let decodeData = try! bytes.decrypt(cipher: getAES128Object())
        
        return String(bytes: decodeData, encoding: .utf8) ?? ""
    }
    
    func getAES128Decrypt(encoded: [UInt8]) -> [UInt8] {
        let datas = Data(encoded)
        
        return try! datas.decrypt(cipher: getAES128Object()).bytes

    }
}
