//
// Created by Igor Efremov on 08/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

enum WalletSyncState: Int {
    case nosync = 0, preparing, connecting, error, syncing, synced

    var description: String {
        switch self {
        case .nosync: return ""
        case .preparing: return l10n(.prepareSync)
        case .connecting: return l10n(.connectingNode)
        case .error: return l10n(.nodeConnectionError)
        case .syncing: return l10n(.syncingState)
        case .synced: return l10n(.syncedState)
        }
    }
}

class SyncWalletBlocksView: UIView {
    private let currentStateLabel: UILabel = UILabel("")
    private let remainingBlocksLabel: UILabel = UILabel("")
    private let syncProgressLoader: EXACircleStrokeLoadingIndicator = EXACircleStrokeLoadingIndicator()
    private let statusIndicatorImageView: UIImageView = UIImageView()
    private let syncProgressBar: UIProgressView = UIProgressView(progressViewStyle: .default)

    var syncHeaderHeight: CGFloat {
        return state == .synced ? 0.0 : 80.0
    }

    var state: WalletSyncState = .nosync {
        didSet {
            currentStateLabel.text = state.description

            switch state {
            case .nosync, .preparing, .connecting, .error, .synced:
                applyLayout()
                remainingBlocksLabel.isHidden = true
                syncProgressLoader.isHidden = true
                syncProgressBar.isHidden = true
            case .syncing:
                if oldValue != .syncing {
                    applyLayout()

                    currentStateLabel.font = UIFont.systemFont(ofSize: 12.0)
                    remainingBlocksLabel.isHidden = false
                    syncProgressLoader.isHidden = false
                    //syncProgressBar.isHidden = false

                    syncProgressLoader.startAnimating()
                }
            }

            if .synced == state {
                syncProgressLoader.stopAnimating()
            }

            if .error == state {
                statusIndicatorImageView.image = EXAGraphicsResources.error
                statusIndicatorImageView.isHidden = false
            } else {
                statusIndicatorImageView.isHidden = true
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initControl()
    }

    func initControl() {
        backgroundColor = UIColor.detailsBackgroundColor
        [currentStateLabel, remainingBlocksLabel, syncProgressBar, statusIndicatorImageView, syncProgressLoader].compactMap{$0}.forEach{addSubview($0)}
    }

    func applyStyles() {
        currentStateLabel.font = UIFont.systemFont(ofSize: 14.0)
        currentStateLabel.textColor = UIColor.valueLabelColor
        currentStateLabel.textAlignment = .left

        remainingBlocksLabel.font = UIFont.systemFont(ofSize: 12.0)
        remainingBlocksLabel.textColor = UIColor.invertedTitleLabelColor
        remainingBlocksLabel.textAlignment = .left

        syncProgressBar.progressTintColor = UIColor.mainColor
        syncProgressBar.trackTintColor = UIColor.lightGray
        syncProgressBar.progress = 0.0
    }

    func applyLayout() {
        currentStateLabel.snp.removeConstraints()
        remainingBlocksLabel.snp.removeConstraints()
        statusIndicatorImageView.snp.removeConstraints()
        syncProgressLoader.snp.removeConstraints()
        syncProgressBar.snp.removeConstraints()

        if state == .syncing {
            currentStateLabel.snp.makeConstraints{ (make) in
                make.left.top.equalToSuperview().offset(20)
                make.width.equalToSuperview()
                make.height.equalTo(16)
            }
        } else {
            currentStateLabel.snp.makeConstraints{ (make) in
                make.left.equalToSuperview().offset(20)
                make.centerY.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(16)
            }
        }

        remainingBlocksLabel.snp.makeConstraints{ (make) in
            make.left.equalTo(currentStateLabel.snp.left)
            make.top.equalTo(currentStateLabel.snp.bottom).offset(2)
            make.width.equalToSuperview()
            make.height.equalTo(16)
        }

        statusIndicatorImageView.snp.makeConstraints{ (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        syncProgressLoader.snp.makeConstraints{ (make) in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }

        syncProgressBar.snp.makeConstraints{ (make) in
            make.right.equalTo(syncProgressLoader.snp.left).offset(-20)
            make.left.equalTo(currentStateLabel.snp.left)
            make.top.equalTo(remainingBlocksLabel.snp.bottom).offset(12)
            make.height.equalTo(2)
        }
    }

    func updateSyncAttempts(_ value: Int) {
        currentStateLabel.text = "Sync... \(value)"
    }

    func updateProgress(_ info: ProgressInfo? = nil, state: WalletSyncState = .syncing) {
        self.state = state

        if let theInfo = info {
            guard theInfo.isValid else { return }
            guard !theInfo.complete else { return }

            if state == .syncing {
                syncProgressBar.isHidden = false
                syncProgressBar.progress = theInfo.progress
                remainingBlocksLabel.text = "Remaining blocks: \(theInfo.remaining)"
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
