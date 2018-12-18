//
// Created by Igor Efremov on 29/05/2019.
// Copyright (c) 2019 Exantech. All rights reserved.
//

import Foundation

public final class AtomicNonce {
    
    private let lock = DispatchSemaphore(value: 1)
    private var _value: UInt64
    
    public init(value initialValue: UInt64 = 0) {
        _value = initialValue
    }
    
    public var value: UInt64 {
        get {
            lock.wait()
            defer { lock.signal() }
            return _value
        }
        set {
            lock.wait()
            defer { lock.signal() }
            _value = newValue
        }
    }
    
    public func incrementAndGet() -> UInt64 {
        lock.wait()
        defer { lock.signal() }
        _value += 1
        return _value
    }
}
