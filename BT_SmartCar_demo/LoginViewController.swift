import UIKit
import Foundation

class LoadingSerivce{
    static func showLoading(){
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            
            let loadingIndicatorView: UIActivityIndicatorView
            
            if let existedView = window.subviews.first(where: {$0 is UIActivityIndicatorView}) as? UIActivityIndicatorView{
                loadingIndicatorView = existedView
            }else{
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                
                loadingIndicatorView.frame = window.frame
                loadingIndicatorView.color = .black
                
                window.addSubview(loadingIndicatorView)
            }
            loadingIndicatorView.startAnimating()
        }
    }
    
    static func hideLoading(){
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            
            window.subviews.filter({$0 is UIActivityIndicatorView})
                .forEach{ $0.removeFromSuperview() }
        }
    }
}

class LoginViewController: UIViewController {
    
    var device: DeviceModel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func tapBackgroundView(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceNameLabel.text = device.name
        
        setKeyboardObserver()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "BluetoothLE Smart Car Service"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.backgroundColor = UIColor(patternImage: (UIImage(named: "dpbgblue_00")!))
        
        titleText.textColor = .white
        deviceNameLabel.textColor = .white
        
        LoadingSerivce.showLoading()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            LoadingSerivce.hideLoading()
        }
        
    }
    
}
extension UIViewController {
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if self.view.window?.frame.origin.y != 0 {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y += keyboardHeight
                }
            }
        }
    }
}
