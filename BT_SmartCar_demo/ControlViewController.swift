import UIKit
import CoreBluetooth

class ControlViewController: UIViewController {

    var connectedPeripheral: CBPeripheral!
    var start: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        self.title = "Control Center"
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func checkStatus(){
        if connectedPeripheral.state == .disconnected {
            print("연결되지 않은 상태")
            disconnectedAlert()
        }
        else if connectedPeripheral.state == .connected {
            print("연결된 상태")
            start = true
        }
    }

    
    /*
     Alert 함수
     */
    func disconnectedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("disconnect", comment: ""), message: NSLocalizedString("connect disconnect msg", comment: ""), preferredStyle: .actionSheet)
        
        let buttonAction = UIAlertAction(title: "확인", style: .cancel, handler: { _ in self.navigationController?.popViewController(animated: true)})
        
        alert.addAction(buttonAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
