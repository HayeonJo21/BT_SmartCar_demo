
import Foundation
import UIKit

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
