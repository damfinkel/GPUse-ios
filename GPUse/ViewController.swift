//
//  ViewController.swift
//  GPUse
//
//  Created by Damian Finkelstein on 5/27/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import UIKit
import GPUImage
import Starscream

class ViewController: UIViewController, WebSocketDelegate {

    let _view: MainScreenView = MainScreenView.loadFromNib()
    private let _socket : WebSocket = WebSocket(url: URL(string: "ws://localhost:3000/FileProcessingChannel")!);
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.goldLabel.text = "0"
        _view.timeLabel.text = "0 seconds"
        
        _socket.delegate = self
        _socket.connect()
    }
    
    // MARK: WebsocketDelegate
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
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

