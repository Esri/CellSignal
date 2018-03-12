// Copyright 2018 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
