//
// Created by Igor Efremov on 2019-02-27.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

class DeviceUID {

    class func uid() -> String {
        let deviceUIDKey = "deviceUID"
        var deviceUIDValue: String

        let ss = SafeStorage()
        if let theDeviceUID = ss.load(deviceUIDKey) {
            deviceUIDValue = theDeviceUID
        } else {
            deviceUIDValue = UUID().uuidString
            ss.save(key: deviceUIDKey, value: deviceUIDValue)
        }

        return deviceUIDValue
    }
}
