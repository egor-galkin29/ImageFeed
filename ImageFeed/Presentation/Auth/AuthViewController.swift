import UIKit

final class AuthViewController: UIViewController {
    let segueIdentificator = "ShowWebView"
    
    @IBOutlet private var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterButton.layer.cornerRadius = 16
    }
}
