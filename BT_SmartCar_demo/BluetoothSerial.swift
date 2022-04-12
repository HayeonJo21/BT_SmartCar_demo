import UIKit
import CoreBluetooth

//블루투스 통신을 담당할 시리얼을 클래스로 선언. CoreBlueTooth를 사용하기 위한 프로토콜 추가
class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager: CBCentralManager!
    //BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate
    var delegate : BluetoothSerialDelegate?
    var pendingPeripheral : CBPeripheral?
    var connectedPeripheral : CBPeripheral?
    let AESUtil = AES128Util()
    
    private var writeType : CBCharacteristicWriteType = .withResponse
    private var writeType_read : CBCharacteristicWriteType = .withResponse

    
    let characteristicUUID_read = CBUUID(string: "69799808-FAD2-4A97-8E34-B877A9D425A7")
    let characteristicUUID_write = CBUUID(string: "F0144D2E-2BAE-46DD-87A2-E588EAE9E2CD")
    var readCharacteristic: CBCharacteristic!
    weak var writeCharacteristic : CBCharacteristic?

   
    
    //central 기기의 블루투스의 on, off상태 변화때마다 호출
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        pendingPeripheral = nil
        connectedPeripheral = nil
    }
    
    //기기 검색 중단
    func stopScan() {
        manager.stopScan()
    }
    
    // 파라미터로 넘어온 주변 기기를 CentralManager에 연결하도록 시도
    func connectToPeripheral(_ peripheral: CBPeripheral)
    {
        print("=== 기기 연결 시도중... ===")
        pendingPeripheral = peripheral
        manager.connect(peripheral, options: nil)
            
    }
    
    // 기기가 검색될 때 마다 호출되는 메서드
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("=== 기기가 검색될 때 마다 호출되는 메서드 ===")
        delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: RSSI)
    }
    
    // 기기가 연결되면 호출되는 메서드
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        
        peripheral.discoverServices(nil)
    }
    
    // service 검색에 성공 시 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        stopScan()
        print("=== 서비스 검색에 성공시 호출되는 메서드 ===")
        if let servicesDes = peripheral.services?.description {
            print("===>" + servicesDes + "<===")
        }
        for service in peripheral.services! {
            print("***** Service: \(service) ******")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // characteristic 검색에 성공 시 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        stopScan()
        print("=== Characteristics 검색에 성공시 호출되는 메서드 ===")
        print("**** " + service.characteristics!.description + " &&&&")
        for characteristic in service.characteristics! {
            print("***** 통신을 위한 설정 시작 ******")
            peripheral.readValue(for: characteristic)

            if characteristic.uuid == characteristicUUID_write{
                print("[CHAR UUID] " + characteristic.uuid.description)
                peripheral.setNotifyValue(true, for: characteristic)
                writeCharacteristic = characteristic
                writeType = characteristic.properties.contains(.write) ? .withResponse : .withResponse
                print("[Write Type] " + writeType.rawValue.description)
                delegate?.serialDidConnectPeripheral(peripheral: peripheral)
            } else if characteristic.uuid == characteristicUUID_read {
                readCharacteristic = characteristic
                writeType_read = readCharacteristic.properties.contains(.write) ? .withResponse : .withResponse
            }
        }
        ScanViewController().connectFailureAlert()
    }
    
    //peripheral로부터 데이터를 전송받으면 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        print("... 전송 받은 데이터가 존재하는지 확인 ...")
        print(".. For characteristic : [\(characteristic.description)]")
        if let data = characteristic.value {
            print("-- 전송 받은 데이터: \(data.bytes.description)")
            print("--- Base64 Encoded String: " + data.base64EncodedString())
            response = data.bytes
        }else{ return }
    }

    
    //String 형식으로 데이터를 주변 기기에 전송
    func sendMessageToDevice(_ message: String){
        
        if let data = message.data(using: String.Encoding.utf8){
            connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
    
    //데이터 Array를 Byte 형식으로 주변기기에 전송
    func sendBytesToDevice(_ bytes: [UInt8]){
        print("... 데이터 전송 메소드 호출 ...")
        let data = Data(bytes)
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
        connectedPeripheral!.writeValue(data, for: readCharacteristic!, type: writeType_read)
    }
    
    //데이터를 주변 기기에 전송
    func sendDataToDevice(_ data:Data){
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }
    
    // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 함수.
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        stopScan()
        if let data = characteristic.value{
//            ControlViewController().decryptDataAndAction(response: data.bytes)
        }else{ return }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI가 호출하는 함수
        // 신호 강도와 관련된 코드를 작성
    }
    
    override init() {
        super.init()
        print("=== bluetooth serial init called ===")
        manager = CBCentralManager.init(delegate: self, queue: .main)
    }
    
}

// 블루투스를 연결하는 과정에서의 시리얼뷰와 소통을 위해 필요한 프로토콜
protocol BluetoothSerialDelegate : AnyObject {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?)
    func serialDidConnectPeripheral(peripheral : CBPeripheral)
}

// 프로토콜에 포함되어 있는일부 함수를 옵셔널로 설정
extension BluetoothSerial: BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?){}
    func serialDidConnectPeripheral(peripheral : CBPeripheral) {}
}
