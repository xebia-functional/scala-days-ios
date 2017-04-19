# ScalaDays for iOS
The official [Scala Days](http://www.scaladays.org) App for Android handcrafted by 47 Degrees. You can download Scala Days from the [App Store](https://itunes.apple.com/us/app/scaladays/id883566471?mt=8 ). If you enjoy the application, please take a moment and rate it in the App Store  :-)

## Setup

This project uses the Cocoapods dependency management system for managing all third party dependencies that are utilized as part of this application. For a list of all of the third party dependencies, view the Podfile.

For setup instructions please see  [cocoapods.org](http://cocoapods.org/)

## Project Installation

To download all of the dependencies, run 'pod install' from the terminal in the folder with the 'Podfile' file.

Once the dependencies are downloaded Cocoapods will create a workspace file. Use the workspace to open the project in Xcode instead of the project file.

## External Keys

As this project uses Crashlytics, Localytics and Google Analytics, an external plist file (**SDExternalKeys.plist**) (located in the *External/Keys* folder) is used to store the API keys for those services. You need to create this file (it's not included in the repository), but you only need to fill the fields if you want to use your own keys for each service. The content is expected to be as follows:

	<dict>
		<key>GoogleAnalytics</key>
		<string>***********</string>
		<key>Crashlytics</key>
		<string>***********</string>
		<key>Localytics</key>
		<string>***********</string>
	</dict>

## Push Notifications

Scala Days has a minimum time between network calls of **four hours**. To override this limit you can send a push notification with the following json key/value pair: 

	jsonReload : true
	
For example, in our case :	

	{"aps":
		{
		 "alert":" Scala Days just added a new event"
		 },
	"jsonReload": true
	}

## Crash Reporting

Crash reporting is handled through Crashlytics. All uncaught exceptions are sent to Crashlytics.

## Functional code

By using Swift in the development of this project we’ve had the chance to bring some **functional programming** aspects to it, i.e.: pattern matching, use of higher-order functions, immutability (wherever possible, Swift 1.2 will let us improve this area further). We consider the Scala Days project as our little first step in the way towards an even more functional development in Apple’s platforms, a target we’re deeply committed to. For a deeper look to what Swift and Scala have in common (in our humble opinion) please refer to this [blog post](http://www.47deg.com/blog/swift-scala).

## License
Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
