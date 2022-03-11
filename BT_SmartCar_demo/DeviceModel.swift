import Foundation
import CoreBluetooth

struct DeviceModel {
    var name: String = ""
    var bssid: String?
    var peripheral: CBPeripheral?
    var vendor: String = ""
    var uuid: String = ""
    var hashCode: Int = 0
    var type: Int = 0
    var major: Int = 0
    var rssi: Float = 0.0
    var risk: Int = 0
    var icon: String = ""
}
