//
// Created by Igor Efremov on 10/08/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

enum EXAEnvironmentType {
    case stage, live
}

protocol EXAEnvironmentProtocol: class {
    var nodes: RemoteMoneroNodesList { get }
    var isMainNet: Bool { get }
}

class EXAEnvironment: EXAEnvironmentProtocol {
    private var _nodes: RemoteMoneroNodesList
    private var _mainNet: Bool
    private var _minStartingBlockForNewWallets: UInt64
#if LIVE
    private let currentBlockHeight: UInt64 = 1842433 // top block on mobile client's release time
#else
    private let currentBlockHeight: UInt64 = 247550
#endif

    var nodes: RemoteMoneroNodesList {
        return _nodes
    }

    var isMainNet: Bool {
        return _mainNet
    }

    var minStartingBlock: UInt64 {
        return _minStartingBlockForNewWallets
    }

    init(_ type: EXAEnvironmentType) {
        switch type {
        case .stage:
            _nodes = RemoteStageMoneroNodesList()
            _mainNet = false
        case .live:
            _nodes = RemoteLiveMoneroNodesList()
            _mainNet = true
        }

        _minStartingBlockForNewWallets = currentBlockHeight
    }
}

class EXAStageEnvironment: EXAEnvironment {
    init() {
        super.init(.stage)
    }
}

class EXALiveEnvironment: EXAEnvironment {
    init() {
        super.init(.live)
    }
}

