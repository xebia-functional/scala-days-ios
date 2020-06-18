# ScalaDays for iOS
The official [Scala Days](http://www.scaladays.org) App for Android handcrafted by 47 Degrees. You can download Scala Days from the [App Store](https://itunes.apple.com/us/app/scaladays/id883566471?mt=8 ). If you enjoy the application, please take a moment and rate it in the App Store  :-)

## Setup

This project uses the Cocoapods dependency management system for managing all third party dependencies that are utilized as part of this application. For a list of all of the third party dependencies, view the Podfile.

For setup instructions please see  [cocoapods.org](http://cocoapods.org/)

## Project Installation

To download all of the dependencies, run 'pod install' from the terminal in the folder with the 'Podfile' file.

Once the dependencies are downloaded Cocoapods will create a workspace file. Use the workspace to open the project in Xcode instead of the project file.

## External Keys

As this project uses TwitterKit and Firebase (Analytics + Crashlytics + Cloud Messaging) frameworks, you need to provide the whole API keys (not included in the repo for security reasons). They are distributed in two external `plist files`, located in the *External/Keys* folder.

**SDExternalKeys.plist**

	<dict>
		<key>TwitterConsumerKey</key>
		<string>***********</string>
		<key>TwitterConsumerSecret</key>
		<string>***********</string>
	</dict>

**GoogleService-Info.plist**

You can find this plist in your [Firebase console](https://firebase.google.com/).

## Crash Reporting

Crash reporting is handled through Crashlytics. All uncaught exceptions are sent to Firebase/Crashlytics.

## License
Copyright (C) 2015-2020 47 Degrees, LLC http://47deg.com hello@47deg.com

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
