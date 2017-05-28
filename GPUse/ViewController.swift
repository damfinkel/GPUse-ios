//
//  ViewController.swift
//  GPUse
//
//  Created by Damian Finkelstein on 5/27/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var bitcore: Bitcore?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if  let address = UserDefaults.standard.string(forKey: "bitcoin.address"),
            let privateKeyWIF = UserDefaults.standard.string(forKey: "bitcoin.privateKeyWIF") {
            print("Address and private key loaded from user defaults")
            print("Address: \(address)")
            print("PrivateKey: \(privateKeyWIF)")
        } else {
            bitcore = Bitcore(parentView: view) { runner in
                runner.createAddress { result in
                    switch result {
                    case .success(let address):
                        print("New address and private key created")
                        print("Address: \(address.value)")
                        print("PrivateKey: \(address.privateKeyWIF)")
                        let store = UserDefaults.standard
                        store.set(address.value, forKey: "bitcoin.address")
                        store.set(address.privateKeyWIF, forKey: "bitcoin.privateKeyWIF")
                        store.synchronize()
                    case .failure(let error):
                        print("Error creating address \(error)")
                    }
                }
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

