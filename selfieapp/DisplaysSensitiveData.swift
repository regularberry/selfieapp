//
//  DisplaysSensitiveData.swift
//  selfieapp
//
//  Created by Sean Berry on 10/1/17.
//  Copyright © 2017 Sean Berry. All rights reserved.
//
import UIKit

protocol DisplaysSensitiveData {
    func hideSensitiveData()
    func showSensitiveData()
}

extension UINavigationController: DisplaysSensitiveData {
    func hideSensitiveData() {
        if let vc = topViewController as? DisplaysSensitiveData {
            vc.hideSensitiveData()
        }
    }
    
    func showSensitiveData() {
        if let vc = topViewController as? DisplaysSensitiveData {
            vc.showSensitiveData()
        }
    }
}
