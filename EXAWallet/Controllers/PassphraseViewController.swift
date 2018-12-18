//
//  PassphraseViewController.swift
//  EXAWallet
//
//  Created by Igor Efremov on 09/01/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

private struct SizeConstants {
    
    static let leftOffset  = 30.0
    static let topOffset   = 10.0
    static let widthOffset = -60.0
}

private typealias s = SizeConstants

final class PassphraseViewController: UIViewController {
    var currentOption: EXAMoneroWalletCreateOption = .createPersonal
    private var mode: EXAWalletPassPhraseMode = .normal
    
    private let headerPhraseLabel: EXALabel = {
        let lbl = EXALabel(l10n(.commonPassphrase))
        lbl.style = .main
        return lbl
    }()
    
    private var phraseTextView: EXAPhraseTextView!
    private let explanationLabel: EXALabel = {
        let lbl = EXALabel(l10n(.createExplanationTitle))
        lbl.numberOfLines = 0
        lbl.style = .main
        return lbl
    }()
    
    private let noteLabel: EXALabel = {
        let lbl = EXALabel(l10n(.commonSafeNote))
        lbl.style = .main
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let continueButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonContinue))
        btn.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)
        return btn
    }()
    
    private let storageService: EXAWalletMetaInfoStorageService = EXAWalletMetaInfoStorageService()

    convenience init(_ currentOption: EXAMoneroWalletCreateOption) {
        self.init(nibName: nil, bundle: nil)
        self.currentOption = currentOption
    }

    convenience init(mode: EXAWalletPassPhraseMode) {
        self.init(nibName: nil, bundle: nil)
        self.mode = mode
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.currentOption = AppState.sharedInstance.tempCurrentOption
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = l10n(.createVcTitle)

        headerPhraseLabel.text = (currentOption == .createPersonal) ? l10n(.commonPassphrase) : l10n(.commonPassphraseEnter)
        phraseTextView = EXAPhraseTextView(restoreMode: currentOption == .restore)

        if currentOption == .restore {
            explanationLabel.text = ""
            noteLabel.text = ""
        }

        
        let allSubviews = [headerPhraseLabel, phraseTextView, explanationLabel, noteLabel, continueButton]
        view.addMultipleSubviews(with: allSubviews)
        
        configPassphrase()
        setupBackButton()
        applyStyles()
        applySizes()

        self.view.addTapTouch(self, action: #selector(switchFirstResponder))
    }
    
    private func configPassphrase() {
        phraseTextView.text = currentPassphrase()
    }
    
    private func currentPassphrase() -> String {
        var result: String = "No enough info"

        guard let wallet = AppState.sharedInstance.currentWallet else {
            return result
        }

        guard let info = AppState.sharedInstance.currentWalletInfo else {
            return result
        }

        switch mode {
        case .normal:
            if currentOption != .restore {
                result = wallet.mnemonic()
            }
        case .remember:
            if info.metaInfo.type == .shared {
                let ss = SharedWalletSeed()
                result = ss.safeLoad(walletId: info.metaInfo.uuid) ?? ""
            } else {
                result = wallet.mnemonic()
            }
        }
        
        return result
    }
    
    private func applySizes() {
        headerPhraseLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(s.leftOffset)
            make.width.equalToSuperview().offset(s.widthOffset)
        }
        
        phraseTextView.snp.makeConstraints { (make) in
            make.top.equalTo(headerPhraseLabel.snp.bottom).offset(s.topOffset)
            make.left.equalToSuperview().offset(s.leftOffset)
            make.width.equalToSuperview().offset(s.widthOffset)
            make.height.equalTo(200)
        }
        
        explanationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phraseTextView.snp.bottom).offset(s.topOffset)
            make.left.equalToSuperview().offset(s.leftOffset)
            make.width.equalToSuperview().offset(s.widthOffset)
        }
        
        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(explanationLabel.snp.bottom).offset(s.topOffset)
            make.left.equalToSuperview().offset(s.leftOffset)
            make.width.equalToSuperview().offset(s.widthOffset)
        }
        
        if mode == .remember {
            continueButton.snp.makeConstraints{ (make) in
                make.width.equalToSuperview().offset(s.widthOffset)
                make.height.equalTo(EXAButton.defaultHeight)
                make.bottom.equalToSuperview().offset(-s.topOffset)
                make.left.equalTo(s.leftOffset)
            }
        } else {
            continueButton.snp.makeConstraints{ (make) in
                make.width.equalToSuperview().offset(s.widthOffset)
                make.height.equalTo(EXAButton.defaultHeight)
                make.top.equalTo(noteLabel.snp.bottom).offset(20)
                make.left.equalTo(s.leftOffset)
            }
        }
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor

        if mode == .remember {
            explanationLabel.isHidden = true
            noteLabel.isHidden = true
            continueButton.setTitle(l10n(.commonOk), for: .normal)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func onTapContinue(_ sender: UIButton) {
        if mode == .remember {
            navigationController?.popViewController(animated: true)
            return
        }

        switch currentOption {
            case .createPersonal, .joinShared, .createShared:
                EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self.navigationController, step: .validatePassphrase)
            case .restore:
                AppState.sharedInstance.restoreMnemonic = phraseTextView.text
                EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(navigationController, step: .fillMetaInfo)
        }
    }

    @objc func switchFirstResponder() {
        phraseTextView.resignFirstResponder()
        self.view.becomeFirstResponder()
    }
}
