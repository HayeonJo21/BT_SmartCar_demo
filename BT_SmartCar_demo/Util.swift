import Foundation

//command 패킷 가져오는 함수
func parseCMDCode(bytes: [UInt8]) -> String{
    let data = bytes.toBase64()
    let cmd = data.split(separator: " ")
    
    return String(cmd[0])
}

//command 패킷을 Hexadecimal로 가져오는 함수
func parseHexCode(bytes: [UInt8]) -> String {
    let data = bytes.toHexString()
    let startIndex = data.index(data.startIndex, offsetBy: 0)
    let endIndex = data.index(data.startIndex, offsetBy: 2)
    
    let cmd = data[startIndex ..< endIndex]
    
    return String(cmd)
}

//문자열의 길이와 함께 hexadecimal format으로 바꾸는 함수
func stringToHex0x(data: String) -> String {
    var result = ""
    
    let lengthHexString = String(format: "%02X", data.count)
    
    result = lengthHexString
    //    result = "0x" + lengthHexString
    
    for i in 0 ... data.count - 1 {
        let item = data[data.index(data.startIndex, offsetBy: i)].description.utf8
        let hexItem = item.map{ String(format: "%02x", $0)}.joined()
        result += hexItem
        //        result += "0x" + hexItem
    }
    
    return result
}

//길이정보 없이 String을 hexadecimal string으로 바꾸는 함수
func stringToHex0xWithoutLength(data: String) -> String {
    var result = ""
    
    for i in 0 ... data.count - 1 {
        let item = data[data.index(data.startIndex, offsetBy: i)].description.utf8
        let hexItem = item.map{ String(format: "%02x", $0)}.joined()
        result += hexItem
    }
    
    return result
}

// 0x00을 추가하여 문자열의 길이를 16바이트로 맞추는 함수
func makingStringLength16(str: String) -> String {
    var result = ""
    
    if str.count > 15 {
    }else if str.count == 15 {
        result = "00"
    }else {
        result = "00"
        for _ in 0 ..< (15 - str.count) {
            result += "00"
        }
    }
    
    return result
}

//hexaString을 String으로 바꾸는 함수
func hexToStr(text: String) -> String {

    let regex = try! NSRegularExpression(pattern: "(0x)?([0-9A-Fa-f]{2})", options: .caseInsensitive)
    let textNS = text as NSString
    let matchesArray = regex.matches(in: textNS as String, options: [], range: NSMakeRange(0, textNS.length))
    let characters = matchesArray.map {
        Character(UnicodeScalar(UInt32(textNS.substring(with: $0.range(at: 2)), radix: 16)!)!)
    }

    return String(characters)
}

// hexaString을 uint8 바이트 배열로 바꾸는 함수
func makingHexStringToByteArray(str: String) -> [UInt8] {
    
    let sliceItemByte = str.hexaBytes
    var result: [UInt8] = []
    
    for i in 0 ..< 16 {
        result.append(sliceItemByte[sliceItemByte.index(sliceItemByte.startIndex, offsetBy: i)])
    }
   
    return result
}

//맥 주소를 파싱하는 함수
func parsingMacAddress(mac: String) -> [UInt8] {
    
    var temp = mac.split(by: 2)
    var item = ""
    
    for i in 0...4 {
        temp[i] += "3A"
    }
    for i in 0...5 {
        item += temp[i]
    }
    
    let result = item.hexaBytes
    
    print(">>> Mac parsing: \(result.debugDescription)")
    
    return result
}

//응답 메시지 로그 가독성을 위한 함수
func logParsing(str: String) ->[String]{
    let log = str.split(by: 2)
    
    return log
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        
        return results.map { String($0) }
    }
}
