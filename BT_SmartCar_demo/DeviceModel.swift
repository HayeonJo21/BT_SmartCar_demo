import Foundation
import CoreBluetooth

struct DeviceModel {
    private var ssid: String
    private var bssid: String
    private var vendor: String
    private var uuid: CBUUID
    private var hashCode: Int
    private var type: Int
    private var major: Int
    private var rssi: NSNumber
    private var risk: Int
    private var icon: String
}
