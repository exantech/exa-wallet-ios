//
// Created by Igor Efremov on 08/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import Foundation

class ProgressInfo {
    static let allowableBlockDiff: UInt64 = 5

    var currentBlock: UInt64 = 0 {
        didSet {
            print("currentBlock is \(currentBlock)")
        }
    }
    var totalBlocks: UInt64 = 0

    var startBlock: UInt64 = 0/* {
        didSet {
            print("startBlock SETUP")
        }
    }*/
    var complete: Bool = false
    var tail: UInt64? {
        //if let theStartBlock = startBlock {
            if totalBlocks < startBlock {
                return 0
            }

            return totalBlocks - startBlock
        //}

        //return nil
    }
    var remaining: UInt64 {
        if currentBlock > totalBlocks {
            return 0
        }

        return totalBlocks - currentBlock
    }
    var progress: Float {
        if let theTail = tail {
            return 1.0 - Float(remaining) / Float(theTail)
        }

        return 0.0
    }

    var isValid: Bool {
        return totalBlocks > 0
    }

    init() {

    }

    func reset() {
        currentBlock = 0
        complete = false
    }

    func setupStartBlock(_ value: UInt64) {
        if value > 0 {
            startBlock = value
        }
    }

    func setupTotalBlock(_ value: UInt64) {
        totalBlocks = value
    }

    func setupCurrentBlock(_ value: UInt64) {
        guard totalBlocks > 0 else { return }

        setupStartBlock(value)
        currentBlock = value
        if currentBlock >= totalBlocks - ProgressInfo.allowableBlockDiff {
            currentBlock = totalBlocks
            complete = true
        }
    }
}
