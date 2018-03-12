cellsignal 
==========================
This repository contains Swift sample code to collect cellular data including capabilities using [ArcGIS Runtime SDK for iOS](http://developers.arcgis.com/en/ios/). The project that can be opened in XCode and instantly run on a simulator or a device.

The ```master``` branch of this repository contains samples configured for the latest available version of [ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/en/ios/). For samples configured for older versions of the SDK,  look under the ```Releases``` tab for a specific version.


## Settings

Go to device settings, find the app CellSignal in the list to change the feature service layer you've created and hosted. The User ID and password settings are for using the service services. 

![Screen Shot](https://github.com/ArcGIS/CellSignal/blob/master/Screenshots/IMG_0087.PNG?raw=true)

## Features

The app needs to be running on the foreground to work, will measure the cell coverage and will send that information to your feature service or, when offline, store it in the device until, connection to the feature service is being restored. The user does not need to interact with the app, only needs to make sure the app is running on the foreground. 

![Screen Shot](https://github.com/ArcGIS/CellSignal/blob/master/Screenshots/IMG_0085.PNG?raw=true)

The chart will show a historical view of the measurements. The scale is from 0 to 4, depending on the cell bars received. 

![Screen Shot](https://github.com/ArcGIS/CellSignal/blob/master/Screenshots/IMG_0086.PNG?raw=true)


## Requirements
* [ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/en/ios/) 100.2.1 (or higher). 
* XCode 9 (or higher)
* iOS 11 SDK (or higher)

1. Fork and then clone the repo. Don't know how? [Get started here.](http://htmlpreview.github.com/?https://github.com/Esri/esri.github.com/blob/master/help/esri-getting-to-know-github.html)
2. Build and run the project to create a single app containing all of the samples.

## Additional Resources

* Want to start a new project? [Setup](https://developers.arcgis.com/ios/latest/swift/guide/install.htm) your dev environment
* New to the API? Explore the documentation : [Guide](https://developers.arcgis.com/ios/latest/swift/guide/introduction.htm) | [API Reference](https://developers.arcgis.com/ios/latest/api-reference/)
* Got a question? Ask the community on our [forum](https://geonet.esri.com/community/developers/native-app-developers/arcgis-runtime-sdk-for-ios/)

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an issue.

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2018 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [license.txt]( https://raw.github.com/Esri/arcgis-runtime-samples-ios/master/license.txt) file.


