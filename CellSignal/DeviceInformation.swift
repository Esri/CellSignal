//
//  DeviceInformation.swift
//  CellSignal
//
//  Created by Al Pascual on 1/23/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import CoreTelephony

public class DeviceInformation: NSObject {

//    "osname": osname,
//    "osversion": osversion,
//    "phonemodel": phonemodel,
//    "deviceid": deviceid
    
    public static var lastCarrier = "Unknown"
    
    public static var deviceID: String {
        get {
            return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        }
    }
    
    public static var  OSName: String {
        get {
            return "iOS"
        }
    }
    
    public static var PhoneModel: String {
        get {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }
    
    public static var OSVersion: String {
        get {
            return UIDevice.current.systemVersion
        }
    }
    
    public static var CarrierID: String {
        get {
            if let carrierName = CTCarrier().carrierName {
                return carrierName
            }
            if let carrierName = CTTelephonyNetworkInfo().subscriberCellularProvider {
                if let carrier = carrierName.carrierName {
                    lastCarrier = carrier
                    return carrier
                }
            }
            return lastCarrier
        }
    }
}
