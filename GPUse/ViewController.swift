//
//  ViewController.swift
//  GPUse
//
//  Created by Damian Finkelstein on 5/27/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {

    let _view: MainScreenView = MainScreenView.loadFromNib()
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.goldLabel.text = "0";
        _view.timeLabel.text = "0 seconds";
    }
    
}

extension UIView {
    /// Loads the nib for the specific view , it will use the view name as the xib name.
    ///
    /// - parameter bundle: Specific bundle, default = mainBundle.
    /// - returns: The loaded UIView
    class func loadFromNib<T: UIView>(_ bundle: Bundle = Bundle.main) -> T {
        let nibName = NSStringFromClass(self).components(separatedBy: ".").last!
        return bundle.loadNibNamed(nibName, owner: self, options: .none)!.first as! T // swiftlint:disable:this force_cast
    }
}

