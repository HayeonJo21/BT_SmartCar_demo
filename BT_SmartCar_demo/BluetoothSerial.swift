//
//  BlueToothSerial.swift
//  BT_SmartCar_demo
//
//  Created by Hayeon on 2022/02/14.
//

import UIKit
import CoreBluetooth

//블루투스 통신을 담당할 시리얼을 클래스로 선언. CoreBlueTooth를 사용하기 위한 프로토콜 추가
class BluetoothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager: CBCentralManager!
    //BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate
    var delegate : BluetoothSerialDelegate?
    var pendingPeripheral : CBPeripheral?  // 현재 연결을 시도하고 있는 블루투스 주변기기
    var connectedPeripheral : CBPeripheral?  // 연결에 성공된 기기. 기기와 통신을 시작할 때 사용하는 객체
    
    weak var writeCharacteristic : CBCharacteristic? // 데이터를 주변에 보내기 위한 chracteristic을 저장하는 변수
    private var writeType : CBCharacteristicWriteType = .withoutResponse //데이터를 주변기기에 보내는 타입 설정
    
    var serviceUUID = CBUUID(string: "FFE0") // Peripheral이 가지고 있는 서비스의 UUID, 거의 모든 HM-10모듈이 갖고있는 FFE0으로 일단 설정.
    
    var characteristicUUID = CBUUID(string: "FFE1")
    
    
    //CBCentralManagerDelegate에 포함되어있는 메서드. central 기기의 블루투스의 on, off상태 변화때마다 호출
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        pendingPeripheral = nil
        connectedPeripheral = nil
    }

    // 기기 검색을 시작할 함수
    func startScan(){
        print("=== 스캔 시작 ===")
        
        switch manager.state {
        case .unknown:
            print(">> 블루투스 상태 알 수 없음 << ")
        case .resetting:
            print(">> 블루투스 서비스 리셋 <<")
        case .unsupported:
            print(">> 기기가 블루투스를 지원하지 않음 <<")
        case .unauthorized:
            print(">> 블루투스 사용 권한 확인 필요 <<")
            intentAppSettings(content: "블루투스 사용 권한을 허용해주세요.")
        case .poweredOff:
            print(">> 블루투스 비활성화 상태 <<")
        case .poweredOn:
            print(">> 블루투스 활성 상태 <<")
            manager.scanForPeripherals(withServices: nil, options: nil)
        @unknown default:
            print(">> 블루투스 케이스 디폴트 <<")
        }
        
        
  
//        let peripherals = manager.retrieveConnectedPeripherals(withServices: nil)
//
//        for peripheral in peripherals {
//            delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
//            print("=== peripheral: " + peripheral.description + "===")
//        }
    }
//
    //기기 검색 중단
    func stopScan() {
        manager.stopScan()
        //centralManager.self
    }
    
    // 파라미터로 넘어온 주변 기기를 CentralManager에 연결하도록 시도
    
    func connectToPeripheral(_ peripheral: CBPeripheral)
    {
        // 연결 실패 시 현재 연결 중인 주변 기기 저장
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
        
        peripheral.discoverServices([serviceUUID])
    }
    
    // service 검색에 성공 시 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    // characteristic 검색에 성공 시 호출되는 메서드
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            // 검색된 모든 characteristic에 대해 UUID를 한번 더 체크하고, 일치한다면 peripheral을 구독하고 통신을 위한 설정 완료
            if characteristic.uuid == characteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                writeCharacteristic = characteristic
                writeType = characteristic.properties.contains(.write) ? .withResponse : .withResponse
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 함수.
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI가 호출하는 함수
        // 신호 강도와 관련된 코드를 작성
    }
    
    override init() {
        super.init()
        print("=== bluetooth serial init called ===")
        manager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    
    func intentAppSettings(content: String){
        let settingAlert = UIAlertController(title: "권한 설정 알람", message: content, preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            // 확인버튼 클릭 이벤트 내용 정의 실시
            if let url = URL(string: UIApplication.openSettingsURLString) {
                print("앱 설정 화면 이동")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        settingAlert.addAction(okAction)

//        let noAction = UIAlertAction(title: "취소", style: .default){ (action) in return}

//        settingAlert.addAction(noAction)
//        present(settingAlert, animated: true, completion: nil)
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
