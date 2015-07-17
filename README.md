# MODE-iOSSDK

[![CI Status](http://img.shields.io/travis/Naoki Takano/MODE-iOSSDK.svg?style=flat)](https://travis-ci.org/Naoki Takano/MODE-iOSSDK)
[![Version](https://img.shields.io/cocoapods/v/MODE-iOSSDK.svg?style=flat)](http://cocoapods.org/pods/MODE-iOSSDK)
[![License](https://img.shields.io/cocoapods/l/MODE-iOSSDK.svg?style=flat)](http://cocoapods.org/pods/MODE-iOSSDK)
[![Platform](https://img.shields.io/cocoapods/p/MODE-iOSSDK.svg?style=flat)](http://cocoapods.org/pods/MODE-iOSSDK)

## Overview
MODE-iOSDK provides API call wrapper to [MODE cloud](http://www.tinkermode.com) and handles the data to connect iOS app, devices and smart modules.

You can write MODE cloud iOS app without this SDK, but it makes developers easier to use MODE cloud to communicate each other with IoT devices.

## Requirements

You need to use the SDK on at least iOS7 platform. The library depends on [Mantle](https://github.com/Mantle/Mantle) and [SocketRocket](https://github.com/square/SocketRocket). See more detail `MODE-iOSSDK.podspec`.

## Installation

MODE-iOSSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MODE-iOSSDK"
```

## Classes

All classes start with `MODE` as prefix.

### MODEAppAPI
`MODEAppAPI.h` defines API wrappter classes to call `MODE cloud` service from `App`. Each function is corresponding to [each MODE cloud API](http://dev.tinkermode.com/api/api_reference.html).

All function calls are aysnc, so you need to pass callback function as `Objective-C` block and check `NSError` object when the block is called. Whenever an error happens, `NSError` has non-`nil`. Otherwise it means success to call.

All callback block is called in main GUI thread as default behavior. So you can call other UI related APIs from callback. If you want to change the behavior, please set `EXECUTE_BLOCK_IN_MAIN_THREAD` macro value to `0` in `ModeApp.m`.

The detail parameter meaning is written in `ModeApp.h` as comments.

### MODEData
`ModeData.h` defines data classes and each class corresponding to each JSON data at [Data Model Reference](http://dev.tinkermode.com/api/model_reference.html). All JSON data is parsed and stored to each properties as proper type in the class.  But `eventData` in `MODEDeviceEvent` is `NSDictionary`, because it can be defined by developers.

The classes are sub-classes of `MTLModel`, so you can use nifty [Mantle](https://github.com/Mantle/Mantle) functions.

### MODEEventListener
`MODEEventListener` is a class to receive events delivered by `MODE cloud`. So you need to keep connection to `MODE cloud` and don't delete the object while `App` is waiting for events.


## Simple example

The following is a simple example code to listen to events. The sample code doesn't check errors, so you need more error checks if you want to reuse the code.

You need to define a project on `MODE cloud` console page. Also you need to define `appId` on the page. If you want to know detail what are `appId` and `projectId`, please read [Getting Started with MODE](http://dev.tinkermode.com/tutorials/getting_started.html). Here we assume, `projectId` is `1234` and `appId` is `SampleApp1`

~~~
    // You have to trigger somewhere with button or menu.
    [MODEAppAPI initiateAuthenticationWithSMS:1234 phoneNumber:@"YOUR PHONE NUMBER"
        completion:(void(^)(MODESMSMessageReceipt* obj, NSError* err)){ /* Need to error check */ };
~~~

Then you can get verification code via SMS. Please set the code into the following `CODE VIA SMS`. Then your App can listen to the events coming from devices or Smart Modules.

~~~
  MODEEventListener* listener = nil; // Maybe you should define as property in the class to keep the object alive.

  [MODEAppAPI authenticateWithCode:1234 phoneNumber:@"YOUR PHONE NUMBER" appId:@"SampleApp1" code:@"CODE VIA SMS"
      completion:(void(^)(MODEClientAuthentication* auth, NSError* err)){

        listner = [[MODEEventListener alloc] initWithClientAuthentication:auth]; 

        [listener startListenToEvents:^(MODEDeviceEvent* event, NSError* err){
          if (event) {
            NSLog(@"Event: %@", event);
          }

        }];
      }];
~~~

## Example App

Go to `Example` directory and run
~~~
$ pod install
~~~

Then open `MODE-iOSSDK.xcworkspace` with Xcode. 

Before you run your app, you have to setup `Project` and `App` on [MODE developer console](https://console.tinkermode.com/). If you are not sure, please read (our documentation)[http://dev.tinkermode.com/docs/] first.

i* 

Find your `App ID` and `Project ID` on the console. Open `LMDataHolder.m` on Xcode. Please find the following lines.

~~~
    if (self) {
        self.members = [[LMDataHolderMembers alloc] init];
        
        // You need to setup projectId and appId according to your project and App settings.
        // Please see more detail (http://dev.tinkermode.com/tutorials/getting_started.html) to get them.
        self.projectId = 12345;
        self.appId = @"AppID";
    }
~~~

You need to replace `12345` to your own `Project ID` and `AppID` to your won `App ID`.


Build the app. You can see `Lumos` logo as following.

![Lumos Logo](/Example/MODE-iOSSDK/Images.xcassets/Lumos_logo.png)

## Author

Naoki Takano, honten@tinkermode.com

## License

MODE-iOSSDK is available under the MIT license. See the LICENSE file for more info.
