//
//  DynamicKeys.swift
//  DynamicCow
//
//  Created by ethernal on 11/01/23.
//

import Foundation

enum DynamicKeys: String, CaseIterable{
    case isEnabled = "isEnabled"
    case currentSet = "currentSet"
    case originalDeviceSubType = "OriginalDeviceSubType"
}

extension UserDefaults {
    func resetAppState(){
        DynamicKeys.allCases.forEach{
            removeObject(forKey: $0.rawValue)
        }
    }
}
