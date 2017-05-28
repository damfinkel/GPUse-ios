//
//  Bitcore.swift
//  GPUse
//
//  Created by Guido Marucci Blas on 5/27/17.
//  Copyright © 2017 Wolox. All rights reserved.
//

import Foundation
import WebKit

enum BitcoreError: Error {
 
    case invalidReponse
    case executionFailure(Error)
    
}

final class Bitcore: NSObject, WKNavigationDelegate {
    
    enum Result<ValueType, ErrorType: Error> {
        
        case success(ValueType)
        case failure(ErrorType)
        
    }
    
    struct PrivateAddress {
        
        let value: String
        let privateKeyWIF: String
        
    }
    
    fileprivate let webView: WKWebView
    fileprivate let onLoad: (Bitcore) -> Void
    
    init(parentView: UIView, onLoad: @escaping (Bitcore) -> Void = { _ in }) {
        self.webView = WKWebView()
        self.onLoad = onLoad
        super.init()
        self.webView.navigationDelegate = self
        parentView.addSubview(webView)
        
        guard
            let jsBundlePath = Bundle.main.path(forResource: "bundle", ofType: "js").flatMap({ URL(fileURLWithPath: $0 )}),
            let jsIndexPath = Bundle.main.path(forResource: "index", ofType: "html").flatMap({ URL(fileURLWithPath: $0 )}) else {
                print("Cannot load resources!")
                return
        }
        
        webView.loadFileURL(jsIndexPath, allowingReadAccessTo: jsBundlePath)
    }
    
    func createAddress(_ completion: @escaping (Result<PrivateAddress, BitcoreError>) -> Void) {
        webView.evaluateJavaScript("BitcoreBridge.createAddress()") { maybeResult, maybeError in
            if let error = maybeError {
                completion(.failure(.executionFailure(error)))
            } else if let result = maybeResult as? [AnyHashable : Any],
                let address = result["address"] as? String,
                let privateKeyWIF = result["privateKeyWIF"] as? String {
                let privateAddress = PrivateAddress(value: address, privateKeyWIF: privateKeyWIF)
                completion(.success(privateAddress))
            } else {
                completion(.failure(.invalidReponse))
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoad(self)
    }
    
}
