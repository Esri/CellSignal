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

import Foundation

class SettingsBundleHelper {
    
    // TEST https://services.arcgis.com/W6FrZiZ4flx7mLJe/arcgis/rest/services/SignalReadings/FeatureServer/0
    // PUBLISH https://services.arcgis.com/W6FrZiZ4flx7mLJe/arcgis/rest/services/SignalReadings_pilot/FeatureServer/0
    
    private static let TEST = "https://services.arcgis.com/W6FrZiZ4flx7mLJe/arcgis/rest/services/SignalReadings/FeatureServer/0"
    private static let RELEASE = "https://services.arcgis.com/W6FrZiZ4flx7mLJe/arcgis/rest/services/SignalReadings_pilot/FeatureServer/0"
    
    // TODO is set for testing right now, need to change that before publishing it
#if DEBUG
    static let featureServiceToUse = TEST
#else
    static let featureServiceToUse = RELEASE
#endif
    
    struct SettingsBundleKeys {
        static let Password = "settings_password"
        static let Username = "settings_username"
        static let FeatureService = "settings_feature_service"
        static let WebMap = "settings_webmap"
        static let Portal = "settings_portal"
    }
    
    class func registerSettingsBundle(){
        let appDefaults = [String:Any]()
        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
    }
}
