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
    fileprivate let _client : ActionCableClient = ActionCableClient(url: URL(string: "wss://823b2419.ngrok.io/cable?address=holacapi")!);
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
    
    func fetchImage(urlString: String, handler: @escaping (UIImage) -> ()) {
        let fileUrl = urlString
        
        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: URLRequest(url:URL(string: fileUrl)!)) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        DispatchQueue.main.sync {
                            handler(UIImage(data: imageData)!)
                        }
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    func filteredImage(image : UIImage) -> UIImage {
        let filter = ColorInversion()
        return image.filterWithOperation(filter)
    }

}

extension ViewController {
    
    func subscribeToChannel() {
        // Create the Room Channel
        if let roomChannel = _roomChannel {
            // Receive a message from the server. Typically a Dictionary.
            roomChannel.onReceive = { [unowned self] (JSON : Any?, error : Error?) in
                print("Received", JSON, error)
                if let data = JSON as? Dictionary<String, Any>, let fileUrl = data["url"] as? String {
                    let fullUrl = "https://823b2419.ngrok.io/" +  fileUrl;
                    self.fetchImage(urlString: fullUrl) { [unowned self] image in
                        let filteredImage = self.filteredImage(image: image)
                        self._view.testImage.image = filteredImage
                    }
                }
            }
            
            // A channel has successfully been subscribed to.
            roomChannel.onSubscribed = {
                print("Yay!")
                roomChannel.action("ready", with: ["message": "Hello, World!"])
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
        
        _client.onConnected = { [unowned self] in
            if (self._roomChannel == nil) {
                self._roomChannel = self._client.create("FileProcessingChannel")
            }
            self.subscribeToChannel()
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

