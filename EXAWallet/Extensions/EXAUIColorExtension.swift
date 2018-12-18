//
// Created by Igor Efremov on 23/03/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import UIKit

extension UIColor {
    class func rgb(_ rgb: Int) -> UIColor {
        let red: CGFloat = CGFloat((rgb & 0xff0000) >> 16)
        let green: CGFloat = CGFloat((rgb & 0x00ff00) >> 8)
        let blue: CGFloat = CGFloat(rgb & 0x0000ff)

        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }

    class func rgba(_ rgba: UInt32) -> UIColor {
        let red: CGFloat = CGFloat((rgba & 0xff000000) >> 24)
        let green: CGFloat = CGFloat((rgba & 0x00ff0000) >> 16)
        let blue: CGFloat = CGFloat((rgba & 0x0000ff00) >> 8)
        let alpha: CGFloat = CGFloat(rgba & 0x000000ff)

        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha/255.0)
    }

    class func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }

    class func rgba(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha/255.0)
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
