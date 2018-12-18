//
// Created by Igor Efremov on 04/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

protocol RemoteMoneroNodesList: class {
    var defaultNode: String { get }
    var currentNode: String { get set }
    var nodes: [String] { get }
}

class RemoteBaseMoneroNodesList: RemoteMoneroNodesList {
    private var _currentNode: String? = nil
    private var _nodes: [String]? = nil

    var defaultNode: String {
        return ""
    }

    var currentNode: String {
        get {
            return _currentNode ?? defaultNode
        }

        set {
            _currentNode = newValue
        }
    }

    var nodes: [String] {
        return [defaultNode]
    }
}

class RemoteStageMoneroNodesList: RemoteBaseMoneroNodesList {
    override var defaultNode: String {
        return "monero-stagenet.exan.tech:38081"
    }
}

class RemoteLiveMoneroNodesList: RemoteBaseMoneroNodesList {
    override var defaultNode: String {
        return "monero.exan.tech:18081"
    }

    override var nodes: [String] {
        return ["monero.exan.tech:18081", "monero1.exan.tech:18081", "opennode.xmr-tw.org:18089"]
    }
}
