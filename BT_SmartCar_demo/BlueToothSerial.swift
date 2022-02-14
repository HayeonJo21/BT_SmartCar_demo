//
//  BlueToothSerial.swift
//  BT_SmartCar_demo
//
//  Created by Hayeon on 2022/02/14.
//

import UIKit
import CoreBluetooth

//블루투스 통신을 담당할 시리얼을 클래스로 선언. CoreBlueTooth를 사용하기 위한 프로토콜 추가
class BlueToothSerial: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager : CBCentralManager! //주변 기기 검색, 연결
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

    
    
}
