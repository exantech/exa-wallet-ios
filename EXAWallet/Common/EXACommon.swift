//
// Created by Igor Efremov on 07/09/15.
// Copyright (c) 2015 Exantech. All rights reserved.
//

import Foundation

class EXACommon {
    class func loadApiKey(_ name: String) -> String? {
        guard let theApiKeyFile = EXACommon.localResourceUrl(name, withExtension: nil) else {
            return nil
        }
        
        do {
            let apiKey = try String(contentsOf: theApiKeyFile, encoding: .utf8)
            return apiKey
        }
        catch {
            return nil
        }
    }
    
    class func localResourceUrl(_ name: String, withExtension ext: String?) -> URL? {
        return Bundle.main.url(forResource: name, withExtension: ext)
    }

    static let dotSymbol = "."
    static let commaSymbol = ","

    static var cacheDirectory: String? {
        return EXACommon.getDirectory(.cachesDirectory)
    }
    
    static var documentsDirectory: String? {
        return EXACommon.getDirectory(.documentDirectory)
    }

    static var dotLocale: String {
        return Locale.current.decimalSeparator ?? EXACommon.dotSymbol
    }

    class func l10n(_ string: String) -> String {
        return NSLocalizedString(string, comment: "")
    }
    
    class func getDirectory(_ type: FileManager.SearchPathDirectory) -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(type, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard paths.count > 0 else { return nil }
        return paths[0]
    }

    class func random(_ upperBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }

    class func saveTestInfo(_ value: String?, storageFileName: String) {
        guard let value = value else { return }
#if TEST
        var path = "/Users/"
        let projectPath = MoneroCommonConstants.projectPath

        let homePath = NSHomeDirectory().components(separatedBy: "/")
        guard homePath.count > 2 else { return }

        path = path.appendPathComponent(homePath[2])
        path = path.appendPathComponent(projectPath)
        path = path.appendPathComponent(storageFileName)
        _ = try? value.write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
#endif
    }

    class func loadTestInfo(_ storageFileName: String) -> String? {
#if TEST
        var path = "/Users/"
        let projectPath = MoneroCommonConstants.projectPath

        let homePath = NSHomeDirectory().components(separatedBy: "/")
        guard homePath.count > 2 else { return nil }

        path = path.appendPathComponent(homePath[2])
        path = path.appendPathComponent(projectPath)
        path = path.appendPathComponent(storageFileName)

        do {
            let inviteCode = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            return inviteCode
        }
        catch {
            return nil
        }
#else
        return nil
#endif
    }
}
