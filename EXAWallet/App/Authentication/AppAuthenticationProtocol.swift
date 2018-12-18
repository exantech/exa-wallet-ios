//
// Created by Igor Efremov on 17/10/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum PinCodeMode {
    case validate
    case change
    case deactive
    case create
}

protocol AppAuthenticationProtocol {
    var state: AppAuthenticationStateHandler? { get set }
    var onPresentPin: DefaultCallback? { get set }
    var onCancelCreate: DefaultCallback? { get set }
    var onDismissBiometryScreen: DefaultCallback? { get set }
    func proceed(with mode: PinCodeMode)
}
