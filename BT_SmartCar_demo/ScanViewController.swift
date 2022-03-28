import UIKit
import CoreBluetooth

var flag = 0
var serial: BluetoothSerial! = BluetoothSerial.init()
var goodColor = UIColor.green.withAlphaComponent(0.55)
var normalColor = UIColor.yellow.withAlphaComponent(0.55)
var warningColor = UIColor.red.withAlphaComponent(0.55)

class ScanViewController: UIViewController, BluetoothSerialDelegate {
    
    @IBOutlet weak var scanListTableView: UITableView!
    var peripheralList : [(peripheral: CBPeripheral, RSSI : Float)] = []
    var deviceModel: DeviceModel!
    var deviceList: [DeviceModel] = []
    var pastScanList: [DeviceModel] = []
    
    let options: [String : Any] = [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(value: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Device Scan List"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        makeNavigationItem()
        
        peripheralList = []
        pastScanList = []
        deviceList.removeAll()
        
        scanListTableView.delegate = self
        scanListTableView.dataSource = self
        initRefresh()
        
        scanListTableView.register(UINib(nibName: "ScanTableViewCell", bundle: nil), forCellReuseIdentifier: "ScanTableViewCell")
        
        scanListTableView.backgroundColor = .clear
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        serial.delegate = self
        self.startScan()
        
    }
    
    //네비게이션 뷰 아이템 설정
    func makeNavigationItem(){
        let stopItem = UIBarButtonItem(image: UIImage(systemName: "stop.circle"), style: .done, target: self, action: #selector(stopScanning))
        
        stopItem.tintColor = .black
        
        self.navigationItem.rightBarButtonItem = stopItem
    }
    
    
    // 기기 검색을 시작할 함수
    func startScan(){
        print("=== 스캔 시작 ===")
        
        switch serial.manager.state {
        case .unknown:
            self.undefinedAlert()
        case .resetting:
            //블루투스 서비스 리셋
            break
        case .unsupported:
            //기기가 블루투스를 지원하지 않음
            break
        case .unauthorized:
            //블루투스 사용권한 확인 필요
            self.intentAppSettings(content: NSLocalizedString("authorization confirm msg", comment: "블루투스 권한 확인 메시지"))
        case .poweredOff:
            powerOffAlert()
            break
        case .poweredOn:
            //블루투스 활성상태
            serial.manager.scanForPeripherals(withServices: nil, options: options)
            //serial.manager.registerForConnectionEvents(options: matchingOptions)
        @unknown default:
            break
        }
    }
    
    func intentAppSettings(content: String){
        let settingAlert = UIAlertController(title: NSLocalizedString("authotization alert", comment: ""), message: content, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                //앱 설정화면 이동
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        settingAlert.addAction(okAction)
        self.present(settingAlert, animated: true, completion: nil)
       
    }
    
    //Refresh 초기 설정
    func initRefresh(){
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateTableView(refresh:)), for: .valueChanged)
        
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        
        if #available(iOS 10.0, *){
            scanListTableView.refreshControl = refresh
        }else{
            scanListTableView.addSubview(refresh)
        }
    }
    
    @objc func updateTableView(refresh: UIRefreshControl){
        peripheralList.removeAll()
        deviceList.removeAll()
        serial.manager.scanForPeripherals(withServices: nil, options: nil)
        refresh.endRefreshing()
        scanListTableView.reloadData()
    }
    
    
    @objc func stopScanning() {
        print("=== 스캔 중지 ===")
        serial.stopScan()
        stopAlert()
    }
    
    /**
     Alert 함수들
     */
    func stopAlert(){
        let alert = UIAlertController(title: NSLocalizedString("stop scanning", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func connectFailureAlert(){
        let alert = UIAlertController(title: NSLocalizedString("connect failure", comment: ""), message: NSLocalizedString("connect failure msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func successConnectionAlert(){
        let connectSuccessAlert = UIAlertController(title: NSLocalizedString("connect success", comment: ""), message: NSLocalizedString("connect success msg", comment: ""), preferredStyle: .actionSheet)
        
        let confirm = UIAlertAction(title: "확인", style: .default, handler: {_ in self.dismiss(animated: true, completion: nil)})
        
        connectSuccessAlert.addAction(confirm)
        self.present(connectSuccessAlert, animated: true, completion: nil)
    }
    
    func undefinedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("bluetooth status alert", comment: ""), message: NSLocalizedString("back to home alert", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func powerOffAlert(){
        let alert = UIAlertController(title: NSLocalizedString("powerOff alert", comment: ""), message: NSLocalizedString("powerOff alert msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // 기기 검색때마다 호출
    func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        print("=== ScanViewController: 프로토콜 함수 호출 ===")
        
        deviceModel = DeviceModel()
        
        //중복 MAC Address 검사
        for item in peripheralList {
            if item.peripheral.identifier == peripheral.identifier {
                return
            }
        }
        
        // 이름이 없는 device 걸러내기
        if peripheral.name == nil || peripheral.name == "" {
            return
        }
        
        print(">> 최종 검색된 디바이스: " + peripheral.description)
        
        let fRSSI = RSSI?.floatValue ?? 0.0
        let uuidString = peripheral.identifier.uuidString
        
        deviceModel.uuid = uuidString
        deviceModel.rssi = fRSSI
        
        if let hasName = peripheral.name {
            deviceModel.name = hasName
        }else{
            return
        }
        
        // 이름 길이 및 Mac Address 변경 여부 확인하여 risk 측정
        deviceModel.risk = setRiskOfDevice(device: peripheral)
        deviceModel.peripheral = peripheral
        
        deviceList.append(deviceModel)
        pastScanList.append(deviceModel)
        
        peripheralList.append((peripheral: peripheral, RSSI: fRSSI))
        peripheralList.sort { $0.RSSI < $1.RSSI }
        
        scanListTableView.reloadData()
    }
    
    
    // 기기 위험도 측정 함수
    func setRiskOfDevice(device: CBPeripheral) -> Int {
        var risk: Int = 0
        
        //이름이 50자 이상인지 확인
        if let name = device.name{
            if name.count >= 50 {
                risk += 2
            } else if name.count >= 40 && name.count < 50 {
                risk += 1
            }
            
            //재 스캔시 이전 스캔된 Device의 MAC Address가 변경되었는지 확인
            if !pastScanList.isEmpty{
                for pastDevice in pastScanList {
                    print(">>> 재 스캔 검사 <<<")
                    if let name = device.name {
                        if pastDevice.name == name {
                            if device.identifier.uuidString != pastDevice.uuid {
                                risk += 10
                            }
                        }
                    }
                }
            }
        }
        return risk
    }
    
    //연결 성공시 호출되는 함수
    func serialDidConnectPeripheral(peripheral: CBPeripheral) {
        print("연결 성공시 호출")
        
        serial.delegate = nil
        successConnectionAlert()

        let msg: [UInt8] = [0x12, 0x01, 0x43, 0x41, 0x4E, 0x01]
        serial.sendBytesToDevice(msg)
            
        DispatchQueue.main.async() {
            flag = 1
            LoadingSerivce.hideLoading()
        }
    }
}

/**
 테이블 뷰 delegate 구현
 */  
extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as? ScanTableViewCell else {
            return UITableViewCell()
        }
        
        let peripheralName = deviceList[indexPath.row].name
        
        
        cell.updatePeripheralsName(name: peripheralName)
        
        
        // 위험도에 따른 색 지정
        if deviceList[indexPath.row].risk < 5 {
            cell.severityImageView.backgroundColor = goodColor
        }else if deviceList[indexPath.row].risk > 4 && deviceList[indexPath.row].risk < 9 {
            cell.severityImageView.backgroundColor = normalColor
            
        }else if deviceList[indexPath.row].risk > 8 {
            cell.severityImageView.backgroundColor = warningColor
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        serial.stopScan()
        
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginVC.device = deviceList[indexPath.row]
        
        if let selectedPeripheral = deviceList[indexPath.row].peripheral {
            print("연결 시도 >>> " + selectedPeripheral.description + "<<<")
            loginVC.device_peripheral = selectedPeripheral
            serial.connectToPeripheral(selectedPeripheral)
        } else { return }
        
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}

func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
    print("블루투스 스캔 NAME: \(String(peripheral.name ?? "null"))")
}

//func addRiskList(device: DeviceModel) -> Int{
//        if device.risk >= 9 {
//            var eqaul = false
//            if !riskList.isEmpty {
//                for dev in riskList {
//                    if dev.name == device.name {
//                        eqaul = true
//                        break
//                    }
//                }
//            }
//            if !eqaul {
//                riskList.append(device)
//            }
//        } else {
//            if !riskList.isEmpty{
//                for dev in riskList {
//                    if dev.name == device.name{
//                        return 10
//                    }
//                }
//            }
//        }
//
//        deviceList.append(device)
//        return device.risk
//    }


//이미 연결됐을 때 사용
//let peripherals = serial.manager.retrieveConnectedPeripherals(withServices: [uuid])
//for peripheral in peripherals {
//    serial.delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: NSNumber(value: fRSSI))
//    print("=== peripheral: " + peripheral.description + "===")
//}
