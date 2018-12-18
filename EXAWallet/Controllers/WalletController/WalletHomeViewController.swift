//
// Created by Igor Efremov on 06/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import SDCAlertView
import SwiftyJSON

protocol ProposalDecisionDelegate: class {
    func approveProposal(_ proposal: TransactionProposal)
    func rejectProposal(_ proposal: TransactionProposal)
}

fileprivate struct SizeConstants {
    //static let syncHeaderHeight = 80.0
}

fileprivate typealias sizes = SizeConstants

class WalletHomeViewController: BaseViewController, TransactionsHistoryActionDelegate, WalletSyncManagerNotifier, MultisignatureWalletAPIResultCallback {
    private var syncService: EXAMoneroSyncService? // = EXAMoneroSyncService()

    private let headerView: WalletHeaderView = WalletHeaderView(frame: CGRect.zero)
    private let syncView: SyncWalletBlocksView = SyncWalletBlocksView(frame: CGRect.zero)

    private let emptyView: EmptyTransactionsHistoryView = EmptyTransactionsHistoryView()
    private var transactionsView: TransactionsHistoryView!
    var viewModel: TransactionsViewModel?

    private var timerCheckConnect: Timer?
    private var timerSync: Timer?

    private var attempt = 1

    private var wh: UInt64 = 0// AppState.sharedInstance.currentWallet!.blockHeight()
    private var workItem: DispatchWorkItem?

    var queue = OperationQueue()
    var forceStopService: Bool = false

    // TODO move api
    private var _api: EXAProposalsAPI!

    // TODO: move to services manager
    private let outputsCoordinator = MultisignatureWalletWorkflowCoordinator(.outputs)
    private var txProposalService: EXAProposalsService?
    private let sendingService = MoneroTransactionsService()
    private let nonceService = EXANonceService.shared

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let meta = AppState.sharedInstance.currentWalletMetaInfo else { return }
        transactionsView = TransactionsHistoryView(walletType: meta.type)
        emptyView.isHidden = true
        emptyView.actionDelegate = self

        transactionsView.isHidden = true
        transactionsView.actionDelegate = self
        transactionsView.proposalActionDelegate = self

        [headerView, syncView, emptyView, transactionsView].compactMap{$0}.forEach{view.addSubview($0)}

        AppState.sharedInstance.syncManager.progress.complete = false
        syncView.isHidden = true

        applyStyles()
        applyLayout()

        if let theWalletInfo = AppState.sharedInstance.currentWalletInfo {
            headerView.walletInfo = theWalletInfo
        }

        //progress.reset()

        let vm = TransactionsViewModel()
        vm.load(history: AppState.sharedInstance.currentWallet) // TODO: change to selected wallet
        viewModel = vm
        if let theViewModel = viewModel {
            if !theViewModel.isEmpty() {
                transactionsView.viewModel = theViewModel
                emptyView.isHidden = true
                transactionsView.isHidden = false
            } else {
                emptyView.isHidden = false
                transactionsView.isHidden = true
            }
        }

        AppState.sharedInstance.syncManager.notifier = self

        _api = EXATransactionProposalsAPIImpl(resultCallback: self)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadProposals),
                name: NSNotification.Name(rawValue: Notification.Name.ProposalsReloadNeeded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCloseWallet),
                name: NSNotification.Name(rawValue: Notification.Name.CloseCurrentWallet), object: nil)
        
        guard let sessionId = AppState.sharedInstance.sessionId(for: meta.uuid) else {
            print("Session Id not defined")
            return
        }
        
        if meta.type == .shared {
            nonceService.getServerNonce(sessionId) { [weak self] (result, nonce) in
                if result == true {
                    self?.startCheckProposal()
                }
            }
        }
    }
    
    func startCheckProposal() {
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self,
                                     selector: #selector(checkProposal), userInfo: nil, repeats: true)
        timer?.fire()
    }

    @objc func checkProposal() {
        txProposalService = EXAProposalsService(transactionService: sendingService)
        txProposalService?.currentProposals()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !AppState.sharedInstance.syncManager.progress.complete {
            syncView.state = .preparing
            syncView.isHidden = false
            startSyncProcess()
        }

        updateTransactionHistoryConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        //timer?.invalidate()
        //stopService()
        super.viewWillDisappear(animated)
    }

    func stopService() {
        //self.forceStopService = true
        //syncService?.test()
        //queue.cancelAllOperations()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        tabBarItem = EXATabBarItem(image: EXAGraphicsResources.homeTab, tag: EXATabScreen.walletHome.rawValue)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.detailsBackgroundColor

        headerView.applyStyles()
        syncView.applyStyles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let theModel = viewModel?.model else { return }

        var proposalPartHeight: CGFloat = 0
        if AppState.sharedInstance.activeProposal.count > 0 {
            proposalPartHeight = CGFloat(AppState.sharedInstance.activeProposal.count) * TransactionsHistoryView.heightForRow + TransactionsHistoryView.heightForHeader
        }
        
        let h = CGFloat(theModel.count) * TransactionsHistoryView.heightForRow + TransactionsHistoryView.heightForHeader + proposalPartHeight
        transactionsView.tableView.contentSize = CGSize(width: view.width, height: h)
    }

    func updateTransactionHistoryConstraints() {
        if syncView.isHidden {
            emptyView.snp.removeConstraints()
            emptyView.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.snp.bottom)
                make.left.width.height.equalToSuperview()
            }

            transactionsView.snp.removeConstraints()
            transactionsView.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.snp.bottom)
                make.left.width.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else {
            emptyView.snp.removeConstraints()
            emptyView.snp.makeConstraints { (make) in
                make.top.equalTo(syncView.snp.bottom)
                make.left.width.height.equalToSuperview()
            }

            transactionsView.snp.removeConstraints()
            transactionsView.snp.makeConstraints { (make) in
                make.top.equalTo(syncView.snp.bottom)
                make.left.width.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }

    func applyLayout() {
        headerView.snp.makeConstraints{ (make) in
            make.top.left.width.equalToSuperview()
            make.height.equalTo(WalletHeaderView.defaultHeight)
        }

        syncView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(syncView.syncHeaderHeight)
        }

        emptyView.snp.makeConstraints { (make) in
            make.top.equalTo(syncView.snp.bottom)
            make.left.width.height.equalToSuperview()
        }

        headerView.applyLayout()
        syncView.applyLayout()
        transactionsView.applySizes()
    }

    @objc private func syncStep() {
        if AppState.sharedInstance.syncManager.isSync {
            let result = AppState.sharedInstance.syncManager.isNeedToUpdateProgress()

            let vm = TransactionsViewModel()
            vm.load(history: AppState.sharedInstance.currentWallet) // TODO: change to selected wallet
            viewModel = vm

            if let theViewModel = viewModel {
                if !theViewModel.isEmpty() {
                    transactionsView.viewModel = theViewModel
                    emptyView.isHidden = true
                    transactionsView.isHidden = false
                } else {
                    emptyView.isHidden = false
                    transactionsView.isHidden = true
                }
            }

            if result.0 {
                AppState.sharedInstance.syncManager.updateProgress(result.1)
                syncView.updateProgress(AppState.sharedInstance.syncManager.progress)

                /*let vm = TransactionsViewModel()
                vm.load(history: AppState.sharedInstance.currentWallet) // TODO: change to selected wallet
                viewModel = vm

                if let theViewModel = viewModel {
                    if !theViewModel.isEmpty() {
                        transactionsView.viewModel = theViewModel
                        emptyView.isHidden = true
                        transactionsView.isHidden = false
                    } else {
                        emptyView.isHidden = false
                        transactionsView.isHidden = true
                    }
                }*/

                guard let theWallet = AppState.sharedInstance.currentWallet else { return }
                headerView.balance = theWallet.formattedBalance()
                headerView.lockedBalance = theWallet.formattedUnconfirmedBalance()
            }
        }
    }

    @objc private func checkConnect() {
        guard let theSyncService = syncService else { return }
        guard let _ = AppState.sharedInstance.currentWallet else { return }
        if theSyncService.isConnected() {
            NSLog("Connected to daemon !!!")
            timerCheckConnect?.invalidate()

            //self.progress.setupTotalBlock(theWallet.networkBlockHeight())

            /*DispatchQueue.main.async { [weak self] in
                if let theSelf = self {
                    theSelf.syncService.startSync(from:theSelf.wh)
                }
            }*/

            /*let currWH = self.progress.currentBlock
            NSLog("Start sync with %u block", currWH)
            NSLog("Remaining %u", self.progress.remaining)*/

            syncView.state = .syncing

            /*workItem = DispatchWorkItem {
                [weak self] in
                //try? rawData.write(to: URL(fileURLWithPath: walletFilePath), options: [.atomic])
                //print("Wallet info saved")
                if let theSelf = self {
                    theSelf.syncService.startSync(from:currWH)
                    DispatchQueue.main.async { [weak self] in
                        self?.timerSync?.invalidate()
                        self?.onSyncStop()
                    }
                }
            }*/

            /*workItem = DispatchWorkItem {
                self.syncService.startSync(from:currWH)
                DispatchQueue.main.async { [weak self] in
                    self?.timerSync?.invalidate()
                    self?.onSyncStop()
                }
            }*/

            /*queue.addOperation{
                self.syncService?.startSync(from:currWH)
                DispatchQueue.main.async { [weak self] in
                    self?.timerSync?.invalidate()
                    self?.onSyncStop()
                }
            }*/

            //DispatchQueue.global(qos: .background).async(execute: workItem!)

            /*DispatchQueue.global(qos: .background).async(execute: { [weak self] in
                //try? rawData.write(to: URL(fileURLWithPath: walletFilePath), options: [.atomic])
                //print("Wallet info saved")
                if let theSelf = self {
                    theSelf.syncService.startSync(from:currWH)
                    DispatchQueue.main.async { [weak self] in
                        self?.timerSync?.invalidate()
                        self?.onSyncStop()
                    }
                }
            })*/

            self.timerSync = Timer.scheduledTimer(timeInterval: 5.0, target: self,
                    selector: #selector(syncStep), userInfo: nil, repeats: true)
        } else {
            NSLog("Not connect yet... waiting")
        }
    }

    // TODO: Refactoring
    func onSyncStop() {
        guard let theWallet = AppState.sharedInstance.currentWallet else { return }

        if forceStopService {
            syncService?.stopSync()
            return
        }

        // TODO check sync stop condition
        let ch = theWallet.currentSyncBlock()
        let nhdiff = 0//nh - ProgressInfo.allowableBlockDiff

        if ch < nhdiff {
            print("Bad Sync!")
            attempt += 1
            syncView.updateSyncAttempts(attempt)
            theWallet.store()

            // TODO resync
            syncService?.pauseSync()
            
            // TODO: Check
            _ = syncService?.initialize()

            self.timerCheckConnect = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                    selector: #selector(checkConnect), userInfo: nil, repeats: true)
        } else {
            /*if progress.complete {
                syncView.state = .synced
                theWallet.store()

                headerView.walletInfo = WalletInfo(AppState.sharedInstance.currentWalletMetaInfo!,
                        balance: theWallet.formattedBalance())

                let vm = TransactionsViewModel()
                vm.load(history: AppState.sharedInstance.currentWallet) // TODO: change to selected wallet
                viewModel = vm
                if let theViewModel = viewModel {
                    if !theViewModel.isEmpty() {
                        transactionsView.viewModel = theViewModel
                        emptyView.isHidden = true
                        transactionsView.isHidden = false
                    }
                }
            }*/
        }
    }

    func doAfterSync() {
        guard let meta = AppState.sharedInstance.currentWalletMetaInfo else { return }
        if .shared == meta.type {
            outputsCoordinator.notifier = self
            outputsCoordinator.start()
        }

        let vm = TransactionsViewModel()
        vm.load(history: AppState.sharedInstance.currentWallet) // TODO: change to selected wallet
        viewModel = vm
        if let theViewModel = viewModel {
            if !theViewModel.isEmpty() {
                transactionsView.viewModel = theViewModel
                emptyView.isHidden = true
                transactionsView.isHidden = false
            } else {
                emptyView.isHidden = false
                transactionsView.isHidden = true
            }
        }

        updateTransactionHistoryConstraints()
    }

    func connecting() {
        syncView.updateProgress(nil, state: .connecting)
    }

    func connectionError() {
        syncView.updateProgress(nil, state: .error)
    }

    func connected() {
        syncView.updateProgress(nil, state: .syncing)
    }

    func syncCompleted() {
        guard let theWallet = AppState.sharedInstance.currentWallet else { return }
        let result = AppState.sharedInstance.syncManager.isNeedToUpdateProgress()
        if result.0 {
            AppState.sharedInstance.syncManager.updateProgress(result.1)
        } else {
            if result.1 == 0 && theWallet.isSynched() {
                AppState.sharedInstance.syncManager.progress.complete = true
            }
        }

        headerView.balance = theWallet.formattedBalance()
        headerView.lockedBalance = theWallet.formattedUnconfirmedBalance()

        if AppState.sharedInstance.syncManager.progress.complete {
            syncView.state = .synced
            theWallet.store()

            headerView.walletInfo = WalletInfo(AppState.sharedInstance.currentWalletMetaInfo!,
                    balance: theWallet.formattedBalance(), lockedBalance: theWallet.formattedUnconfirmedBalance())

            delay(1.0, closure: { [weak self] in
                self?.syncView.snp.updateConstraints { (make) in
                    make.height.equalTo(self?.syncView.syncHeaderHeight ?? 0.0)
                }
                self?.syncView.isHidden = true
            })

            doAfterSync()
        } else {
            let sb = AppState.sharedInstance.syncManager.progress.startBlock
            let tb = AppState.sharedInstance.syncManager.progress.totalBlocks

            if (sb + 5) > tb {
                syncView.state = .synced

                UIView.animate(withDuration: 0.3) {
                    self.syncView.snp.updateConstraints { (make) in
                        make.height.equalTo(self.syncView.syncHeaderHeight)
                    }
                }

                doAfterSync()
            } else {
                print("Sync not completed correct")
            }
        }
}

    private func startSyncProcess() {
        //NSLog("startSyncProcess temporary disabled")
        self.timerSync = Timer.scheduledTimer(timeInterval: 12.0, target: self,
                selector: #selector(syncStep), userInfo: nil, repeats: true)

        //return

        //self.progress.currentBlock = wh

       /* syncService?.initialize()

        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self,
                selector: #selector(checkConnect), userInfo: nil, repeats: true)*/
    }

    func onSelectTransaction(_ index: Int) {
        guard let theViewModel = viewModel else { return }
        guard let theModel = theViewModel.model else { return }
        guard let theItem = theModel.item(index) else { return }

        let vc = TransactionDetailsViewController(theItem)
        navigationController?.setupBackButton()
        navigationController?.pushViewController(vc, animated: true)
    }

    func onSelectProposals(_ index: Int) {
        let proposal = AppState.sharedInstance.activeProposal[index]
        guard !proposal.approved else { return }
        guard !proposal.rejected else { return }
        guard !proposal.alreadySigned else { return }

        let alert = AlertController(title: "To: \(proposal.to)",
                message: proposal.amountString + "\n" + proposal.description,
                preferredStyle: .actionSheet)
        alert.visualStyle = EXAActionSheetVisualStyle(alertStyle: .actionSheet)

        let OKAction = AlertAction(title: l10n(.proposalApprove), style: .destructive) {
            [weak self] (_) in
            if let wSelf = self {
                wSelf.approveProposal(proposal)
            }
        }
        let rejectAction = AlertAction(title: l10n(.proposalReject), style: .normal) {
            [weak self] (_) in
            if let wSelf = self {
                wSelf.rejectProposal(proposal)
            }
        }
        let decideLater = AlertAction(title: "Decide Later", style: .normal)

        alert.addAction(OKAction)
        alert.addAction(rejectAction)
        alert.addAction(decideLater)
        alert.present()
    }

    @objc func reloadProposals() {
        transactionsView.reloadNeeded()
        updateTransactionHistoryConstraints()
    }

    @objc func onCloseWallet() {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    func failure(error: String) {
        EXADialogs.showMessage(error, title: l10n(.commonError), buttonTitle: l10n(.commonOk))
    }
    func completed(result: String) {

    }
    func completed(resultArray: [String]) {

    }
    func completed(stage: MultisigStage) {

    }
    func completed(resultJSON: JSON) {

    }
}

extension WalletHomeViewController: MultisignatureWalletWorkflowNotification {
    func onUpdate(_ text: String, _ invitePhase: Bool) {

    }

    func onUpdate(stage: MultisigStage, result: [Any]?) {

    }

    func onFinish() {

    }

    func onComplete() {}
}

extension WalletHomeViewController: EmptyTransactionsHistoryViewActionDelegate {
    func onRequestSomeMoney() {
        tabBarController?.selectedIndex = 1
    }
}

extension WalletHomeViewController: ProposalDecisionDelegate {
    func approveProposal(_ proposal: TransactionProposal) {
        guard let theIdentifier = proposal.identifier else { return }
        
        showProposalDialog(approveAction: true, completionAction: {  [weak self] in
            self?.innerApproveProposal(proposal, approveAction: { (signedData) in
                self?._api.setupProposalLock(proposalId: theIdentifier, onSuccess: { [weak self] in
                    self?._api.proposalDecision(true, proposalId: theIdentifier,
                                                signedTransaction: signedData, approvalsNonce: EXANonceService.shared.approvalNonce(for: proposal))
                })
            })
        })
    }

    func rejectProposal(_ proposal: TransactionProposal) {
        guard let theIdentifier = proposal.identifier else { return }
        
        showProposalDialog(approveAction: false, completionAction: {  [weak self] in
            self?._api.setupProposalLock(proposalId: theIdentifier, onSuccess: { [weak self] in
                self?._api.proposalDecision(false, proposalId: theIdentifier,
                                            signedTransaction: "", approvalsNonce: EXANonceService.shared.approvalNonce(for: proposal))
            })
        })
    }
    
    private func readyToCommitCondition(_ proposal: TransactionProposal) -> Bool {
        guard let meta = AppState.sharedInstance.currentWalletInfo else { return false }
        return (proposal.approvalsCount + 1 == meta.metaInfo.signatures)
    }
    
    private func innerApproveProposal(_ proposal: TransactionProposal, approveAction: ((String) -> Void)? = nil) {
        // pendingTransaction->multisigSignData()
        let readyToCommit = readyToCommitCondition(proposal)
        if readyToCommit {
            if let theService = txProposalService {
                if theService.signParticipantAndCommit(proposal.lastSignedTransaction) {
                    approveAction?("Success")
                }
            }
        } else {
            if let theService = txProposalService {
                let result = theService.signParticipant(proposal.lastSignedTransaction)
                if result.0 {
                    if let theSignedData = result.1 {
                        approveAction?(theSignedData)
                    }
                }
            }
        }
    }
    
    private func showProposalDialog(approveAction: Bool, completionAction: (() -> Void)? = nil) {
        let message = approveAction ? "Do you want to approve this proposal?" : "Do you really want to reject this proposal?"
        let style: AlertActionStyle = approveAction ? .preferred : .destructive
        let cancelStyle: AlertActionStyle = approveAction ? .destructive : .preferred
        
        let alert = AlertController(title: "Proposal decision", message: message, preferredStyle: .alert)
        alert.visualStyle = EXAAlertVisualStyle(alertStyle: .alert)
        let OKAction = AlertAction(title: l10n(.commonOk), style: style, handler: {
            (action) -> Void in
            completionAction?()
        })
        
        let cancelAction = AlertAction(title: l10n(.commonCancel), style: cancelStyle, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
}
