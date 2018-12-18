//
// Created by Igor Efremov on 21/05/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import UIKit

extension String {
    var length: Int { return self.count }
    var capitalizedOnlyFirst: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }

    // better hash func
    var djb2hash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }

    func replaceCommaWithDot() -> String {
        return self.replacingOccurrences(of: ",", with: EXACommon.dotSymbol)
    }

    func toDouble() -> Double? {
        let preparedStringForCast = replaceCommaWithDot()
        if let result = NumberFormatter().number(from: preparedStringForCast)?.doubleValue {
            return result
        }

        if let result = EXAWalletFormatter.dotNumberFormatter.number(from: preparedStringForCast)?.doubleValue {
            return result
        }

        return EXAWalletFormatter.amountFormatter.number(from: preparedStringForCast)?.doubleValue
    }

    func decimalToHexString() -> String {
        let result = String(Int(self) ?? 0, radix: 16)
        if result.length == 1 {
            return String(format: "0\(result)")
        }

        return result
    }

    func hexData() -> Data? {
        var data = Data(capacity: count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }

        guard data.count > 0 else { return nil }
        return data
    }

    func substring(_ from: Int, length: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(self.startIndex, offsetBy: from + length)
        return String(self[start..<end])
    }

    func substring(from: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(self.startIndex, offsetBy: length)
        return String(self[start..<end])
    }

    func drawInRect(_ rect: CGRect, attributes: [NSAttributedString.Key : Any]?) {
        let attributedString: NSAttributedString = NSAttributedString(string: self, attributes: attributes)
        attributedString.draw(in: rect)
    }

    func boundingRectWithSize(_ size: CGSize, font: UIFont) -> CGRect {
        let str: NSString = NSString(string: self)
        return str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    }

    func boundingWidthWithSize(_ size: CGSize, font: UIFont) -> CGFloat {
        return boundingRectWithSize(size, font: font).size.width
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func appendCRLF() -> String {
        return self + "\r\n"
    }

    func appendPathComponent(_ path: String) -> String {
        let nsString = self as NSString
        return nsString.appendingPathComponent(path)
    }

    func appendPathExtension(_ ext: String) -> String? {
        let nsString = self as NSString
        return nsString.appendingPathExtension(ext)
    }
    
    func leftHexPadding(toLength: Int, withPad character: Character) -> String {
        let sub = String(self.suffix(self.length - 2))
        
        let stringLength = sub.count
        if stringLength < toLength {
            return "0x" + String(repeatElement(character, count: toLength - stringLength)) + sub
        } else {
            return "0x" + String(sub.suffix(toLength))
        }
    }
    
    func hasDecimalSeparator() -> Bool {
        if let theDecimalSeparator = NSLocale.current.decimalSeparator {
            return self.hasSuffix(theDecimalSeparator)
        }
        
        return self.hasSuffix(EXACommon.dotSymbol) || self.hasSuffix(EXACommon.commaSymbol)
    }

    func isSameAddressString(_ addressString: String) -> Bool {
        return self.lowercased() == addressString.lowercased()
    }

    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return digest(input: stringData as NSData).hexString()
        }
        return ""
    }

    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

}
