//
// Created by Igor Efremov on 19/05/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import Foundation
import UIKit

let pass: Any = ()
func noop() {}

struct ScreenSize {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenLength = max(ScreenSize.screenWidth, ScreenSize.screenHeight)
}

struct DeviceType {
    static let isiPhone4AndLess: Bool =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenLength < 568.0
    static let isiPhone5: Bool = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenLength == 568.0
    static let isiPhone6OrMore: Bool = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenLength > 568.0
    static let isiPhone6: Bool = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenLength == 667.0
    static let isiPhone6Plus: Bool = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenLength == 736.0
    static let isiPhoneXOrBetter: Bool = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.screenLength >= 812.0
    static let isiPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    static let isLaunchedOniPad = UIDevice.current.model.range(of: "iPad") != nil
    static let isWideScreen = DeviceType.isiPhone6OrMore
    static let isLongWidthScreen = ScreenSize.screenWidth > 320.0
}

func debug_print(_ object: Any) {
#if DEBUG
    Swift.print(object, terminator: "")
#endif
}

func debug_println(_ object: Any) {
#if DEBUG
    Swift.print(object)
#endif
}

func details_log(_ object: Any) {
#if DETAILS_LOG
    Swift.print(object)
#endif
}

func l10n(_ string: EXALocalizedString) -> String {
    return string.l10n
}

func synchronize(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func delay(_ delay: Double, closure: @escaping ()->()) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: closure)
}

func executionTimeInterval(block: () -> ()) -> CFTimeInterval {
    let start = CACurrentMediaTime()
    block()
    let end = CACurrentMediaTime()
    return end - start
}
