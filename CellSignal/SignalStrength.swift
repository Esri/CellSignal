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

class SignalStrength: NSObject {

    
    public func getSignalStrength() -> Int {
        
        if #available(iOS 11.0, *) {
            return convertToSignal(bars: getSignalStrengthiOS11())
        } else {
            print("TODO: Nothing avaiable!")
        }
        
        return 0
    }
    
    //https://www.igeeksblog.com/how-to-check-the-signal-strength-in-numbers-on-iphone-without-jailbreak/
    
    private func getSignalStrengthiPhoneX() -> Int {
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        
        let statusBar = statusBarView.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBar.value(forKey: "foregroundView") as! UIView
        
        for subview in foregroundView.subviews {
            if subview.subviews.count > 0 {
                for child in subview.subviews {
                    if child.isKind(of: NSClassFromString("_UIStatusBarCellularSignalView")!) {
                        return child.value(forKey: "numberOfActiveBars") as? Int ?? 0
                    }
                }
            }
        }
        return 0
    }
    
    // For non iPhone X Devices
    // Not used right now, we should try to
    // TODO, test this one
    private func getSignalStrengthRest() -> Int {
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews
        
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
    }
    
    private func getSignalStrengthiOS11() -> Int {
        let application = UIApplication.shared
        if let statusBarView = application.value(forKey: "statusBar") as? UIView {
            
            for subbiew in statusBarView.subviews {
                //print("SubView: \(subbiew.classForKeyedArchiver.debugDescription)")

                if isiPhoneX() {
                    
                    return getSignalStrengthiPhoneX()
                    
                } else {
                    if subbiew.classForKeyedArchiver.debugDescription == "Optional(UIStatusBarForegroundView)" {
                        for subbiew2 in subbiew.subviews {
                            //print("SubView 2: \(subbiew2.classForKeyedArchiver.debugDescription)")
                            
                            if subbiew2.classForKeyedArchiver.debugDescription == "Optional(UIStatusBarSignalStrengthItemView)" {
                                
                                let bars = subbiew2.value(forKey: "signalStrengthBars") as! Int
                                //print("bars \(bars)")
                                return bars
                            }
                        }
                    }
                }
            }
        }
        
        return 0 //NO SERVICE
    }
    
    private func isiPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //print("iPhone 5 or 5S or 5C")
                break
            case 1334:
                //print("iPhone 6/6S/7/8")
                break
            case 2208:
                //print("iPhone 6+/6S+/7+/8+")
                break
            case 2436:
                //print("iPhone X")
                return true
            default:
                break
                //print("unknown")
            }
        }
        return false
    }
    
    private func convertToSignal(bars: Int) -> Int {
        
        // Scale is now 0-4 instead of 0-100
        return bars
//        switch bars {
//        case 0:
//            return 0
//        case 1:
//            return 25
//        case 2:
//            return 50
//        case 3:
//            return 75
//        case 4:
//            return 100
//        default:
//            return -1
//        }
    }
    
    // Not working yet, needs to be tested in iOS9
    private func getSignalStrengthiOS9() -> Int {
        
        let application = UIApplication.shared
        let statusBarView = application.value(forKey: "statusBar") as! UIView
        let foregroundView = statusBarView.value(forKey: "foregroundView") as! UIView
        let foregroundViewSubviews = foregroundView.subviews
        
        var dataNetworkItemView:UIView!
        
        for subview in foregroundViewSubviews {
            if subview.isKind(of: NSClassFromString("UIStatusBarSignalStrengthItemView")!) {
                dataNetworkItemView = subview
                break
            } else {
                return 0 //NO SERVICE
            }
        }
        
        return dataNetworkItemView.value(forKey: "signalStrengthBars") as! Int
    }
    
    // Not in used at this time.
    func getSignalStrengthPrivate() -> Int {

        //int CTGetSignalStrength();
        let libHandle = dlopen ("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony", RTLD_NOW)
        let CTGetSignalStrength2 = dlsym(libHandle, "CTGetSignalStrength")
        
        typealias CFunction = @convention(c) () -> Int
        
        if (CTGetSignalStrength2 != nil) {
            let fun = unsafeBitCast(CTGetSignalStrength2!, to: CFunction.self)
            let result = fun()
            print("!!!!result \(result)")
            return result;
            
        }
        return -1
    }
}
