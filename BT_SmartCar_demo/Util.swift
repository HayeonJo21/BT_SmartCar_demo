import Foundation

//command 패킷 가져오는 함수
func parseCMDCode(bytes: [UInt8]) -> String{
    let data = bytes.toBase64()
    let cmd = data.split(separator: " ")
    
    return String(cmd[0])
}

func parseHexCode(bytes: [UInt8]) -> String {
    let data = bytes.toHexString()
    let startIndex = data.index(data.startIndex, offsetBy: 0)
    let endIndex = data.index(data.startIndex, offsetBy: 2)
    
    let cmd = data[startIndex ..< endIndex]
    
    return String(cmd)
}

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

func stringToHex0xWithoutLength(data: String) -> String {
    var result = ""
    
    for i in 0 ... data.count - 1 {
        let item = data[data.index(data.startIndex, offsetBy: i)].description.utf8
        let hexItem = item.map{ String(format: "%02x", $0)}.joined()
        result += hexItem
    }
    
    return result
}


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

func makingHexStringToByteArray(str: String) -> [UInt8] {
    
    let sliceItemByte = str.hexaBytes
    var result: [UInt8] = []
    
    for i in 0 ..< 16 {
        result.append(sliceItemByte[sliceItemByte.index(sliceItemByte.startIndex, offsetBy: i)])
    }
    print(">>> emailHexaItem [UInt8] : \(result.description)")
    print(">>> \(sliceItemByte.toHexString())\n")
    
    return result
}

func parsingMacAddress(mac: String) {
//    var result:[UInt8] = []
    var temp = mac.split(by: 2)
    var item = ""
    var itemString = ""
    
    for i in 0...4 {
        temp[i] += "3A"
    }
    print(">>> temp: \(temp.debugDescription)")
    
    for i in 0...5 {
        item += temp[i]
    }
    print(">>> item: \(item.debugDescription)")

    let hexMac = item.hexaBytes
    
    print(">>> HexaBytes MAC: \(hexMac.debugDescription)")
//
//    return result
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
