//
//  ViewController.swift
//  GPUse
//
//  Created by Damian Finkelstein on 5/27/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import UIKit
import GPUImage
import ActionCableClient

class ViewController: UIViewController {

    let _view: MainScreenView = MainScreenView.loadFromNib()
    fileprivate let _client : ActionCableClient = ActionCableClient(url: URL(string: "wss://763bba6f.ngrok.io/cable")!);
    fileprivate var _roomChannel : Channel?
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.goldLabel.text = "0"
        _view.timeLabel.text = "0 seconds"
        
        _view.connectButton.addTarget(self, action: #selector(ViewController.didPressConnect(sender:)), for: .touchUpInside)
        
        connect()
    }
    
    func readLocalShader() -> String? {
        let file = "File.txt" //this is the file. we will write to and read from it
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(file)
            
            //reading
            do {
                return try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}
        }
        return nil;
    }
    
    func didPressConnect(sender: UIButton) {
//        let path = URL(string:Bundle.main.path(forResource:"File", ofType: "txt")!)
//        do {
//            let myFilter = try BasicOperation(fragmentShaderFile:path!, numberOfInputs:1)
//            let myFilter = try BasicOperation
////            let myFilter = SmoothToonFilter();
//            let testImage = UIImage(named:"heyeyea.jpg")!
//            let filteredImage = testImage.filterWithOperation(myFilter)
//            _view.testImage.image = filteredImage
//        } catch {
//            print("ERROR FILTERING")
//        }
    }
    
    func toJson(dictionary: Dictionary<String, Any>) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:String] {
                return dictFromJSON.description;
            }
        } catch {
            return "invalid string"
        }
        return "invalid string"
    }

}

extension ViewController {
    
    func subscribeToChannel() {
        // Create the Room Channel
        if let roomChannel = _roomChannel {
            // Receive a message from the server. Typically a Dictionary.
            roomChannel.onReceive = { (JSON : Any?, error : Error?) in
                print("Received", JSON, error)
            }
            
            // A channel has successfully been subscribed to.
            roomChannel.onSubscribed = {
                print("Yay!")
            }
            
            // A channel was unsubscribed, either manually or from a client disconnect.
            roomChannel.onUnsubscribed = {
                print("Unsubscribed")
            }
            
            // The attempt at subscribing to a channel was rejected by the server.
            roomChannel.onRejected = {
                print("Rejected")
            }
        }
    }
    
    func connect() {
        // Connect!
        _client.connect()
        
        _client.onConnected = {
            if (self._roomChannel == nil) {
                self._roomChannel = self._client.create("FileProcessingChannel")
            }
            if let roomChannel = self._roomChannel {
                roomChannel.action("ready", with:["address": "asldkjhaskdlahsdajhsd"])
            }
        }
        
        _client.onDisconnected = {(error: Error?) in
            print("Disconnected!")
        }
    }
    
}

extension UIView {

    class func loadFromNib<T: UIView>(_ bundle: Bundle = Bundle.main) -> T {
        let nibName = NSStringFromClass(self).components(separatedBy: ".").last!
        return bundle.loadNibNamed(nibName, owner: self, options: .none)!.first as! T // swiftlint:disable:this force_cast
    }
}

