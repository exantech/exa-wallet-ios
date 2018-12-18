//
// Created by Igor Efremov on 05/07/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit
import SDCAlertView

fileprivate struct SizeConstants {

    static let sideOffset  = 20.0
    static let widthOffset = -60.0
}

fileprivate typealias s = SizeConstants

final class ValidatePassphraseViewController: UIViewController {
    private var sha256Reference: String?
    private var inError: Bool = false
    private var preparedPhrase: String?

    private let headerPhraseLabel: EXALabel = {
        let lbl = EXALabel(l10n(.validatePassphrase))
        lbl.style = .main
        return lbl
    }()

    private let phraseTextView: EXAPhraseTextView = {
        let textView = EXAPhraseTextView(restoreMode: false)
        textView.textAlignment = .center
        textView.sizeToFit()
        return textView
    }()

    private var missedWords: [UILabel] = [UILabel]()

    private let invalidPassphaseWarningLabel: EXALabel = {
        let lbl = EXALabel(l10n(.invalidPassphrase))
        lbl.numberOfLines = 0
        lbl.style = .warning
        return lbl
    }()

    private let explanationLabel: EXALabel = {
        let lbl = EXALabel(l10n(.createExplanationTitle))
        lbl.numberOfLines = 0
        lbl.style = .main
        return lbl
    }()

    private let noteLabel: EXALabel = {
        let lbl = EXALabel("Tap on word in right order")
        lbl.style = .note
        lbl.numberOfLines = 0
        return lbl
    }()

    private let continueButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonContinue))
        btn.addTarget(self, action: #selector(onTapContinue), for: .touchUpInside)
        return btn
    }()

    private let skipButton: EXAButton = {
        let btn = EXAButton(with: l10n(.commonSkip))
        btn.addTarget(self, action: #selector(onTapSkip), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = l10n(.createVcTitle)

        let allSubviews = [headerPhraseLabel, phraseTextView, noteLabel, invalidPassphaseWarningLabel, continueButton, skipButton]
        view.addMultipleSubviews(with: allSubviews)

        configPassphrase()
        setupBackButton()
        applyStyles()
        applySizes()
    }

    private func configPassphrase() {
        let builder = ValidatePassphraseBuilder()
        let fullPhrase = AppState.sharedInstance.currentWallet?.mnemonic()

        sha256Reference = fullPhrase?.sha256()

        let result = builder.prepareForValidate(AppState.sharedInstance.currentWallet?.mnemonic())
        if let words = result.0 {
            preparedPhrase = words.joined(separator: " ")
            phraseTextView.text = preparedPhrase
            for word in result.1! {
                let lbl = UILabel(word, textColor: UIColor.grayTitleColor, font: UIFont.boldSystemFont(ofSize: 16.0))
                lbl.sizeToText()
                lbl.isHighlighted = true
                lbl.highlightedTextColor = UIColor.mainColor
                lbl.addTapTouch(self, action: #selector(onTapWord(_ :)))

                missedWords.append(lbl)
                view.addSubview(lbl)
            }
        }
    }

    private func applySizes() {
        let bottomPadding: CGFloat = DeviceType.isiPhoneXOrBetter ? 34.0 : 0.0

        headerPhraseLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(s.sideOffset)
            make.width.equalToSuperview().inset(s.sideOffset)
            make.height.equalTo(20)
        }

        phraseTextView.snp.makeConstraints { (make) in
            make.top.equalTo(headerPhraseLabel.snp.bottom).offset(s.sideOffset)
            make.width.equalToSuperview().inset(s.sideOffset + 20)
            make.height.equalTo(120)
            make.centerX.equalToSuperview()
        }

        invalidPassphaseWarningLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phraseTextView.snp.bottom).offset(10)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }

        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phraseTextView.snp.bottom).offset(s.sideOffset)
            make.left.width.equalToSuperview()
            make.height.equalTo(20)
        }

        let allMissedWords = missedWords.compactMap{$0.text}.reduce("") { $0 + $1 }
        let allMissedWordsWidth = allMissedWords.boundingWidthWithSize(CGSize(width: self.view.width, height: 20),
                font: UIFont.boldSystemFont(ofSize: 16.0)) + CGFloat((missedWords.count - 1) * 10)
        let offset = ceil((self.view.width - allMissedWordsWidth) / 2)

        for n in 0..<missedWords.count {
            if n == 0 {
                missedWords[0].snp.makeConstraints { (make) in
                    make.top.equalTo(noteLabel.snp.bottom).offset(s.sideOffset)
                    make.left.equalTo(offset)
                }
            } else {
                missedWords[n].snp.makeConstraints { (make) in
                    make.top.equalTo(noteLabel.snp.bottom).offset(s.sideOffset)
                    make.left.equalTo(missedWords[n-1].snp.right).offset(10)
                }
            }
        }

        continueButton.snp.makeConstraints{ (make) in
            make.width.equalToSuperview().inset(s.sideOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(skipButton.snp.top).offset(-20)
        }

        skipButton.snp.makeConstraints{ (make) in
            make.width.equalToSuperview().inset(s.sideOffset)
            make.height.equalTo(EXAButton.defaultHeight)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20 - bottomPadding)
        }
    }

    override func applyStyles() {
        super.applyStyles()
        view.backgroundColor = UIColor.screenBackgroundColor

        invalidPassphaseWarningLabel.isHidden = true
    }

    @objc func onTapContinue(_ sender: UIButton) {
        if inError {
            inError = false
            clearInvalidInfo()
            return
        }

        if checkCorrectOrder(phraseTextView.text) {
            EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(self.navigationController, step: selectNextStep())
        } else {
            inError = true
            displayInvalidInfo()
        }
    }

    @objc func onTapSkip(_ sender: UIButton) {
        showWarningDialog()
    }

    private func selectNextStep() -> WalletSequenceStep {
        let step: WalletSequenceStep

        switch AppState.sharedInstance.tempCurrentOption {
        case .createShared:
            step = .inviteParticipantsAfterCreate
        case .joinShared:
            step = .participantScreenAfterCreate
        case .restore:
            step = .participantScreenAfterCreate
        default:
            step = .postValidationPassphrase
        }

        return step
    }

    private func clearInvalidInfo() {
        explanationLabel.isHidden = false
        noteLabel.isHidden = false
        invalidPassphaseWarningLabel.isHidden = true
        phraseTextView.textColor = UIColor.titleLabelColor
        phraseTextView.layer.borderColor = UIColor.clear.cgColor
        phraseTextView.layer.borderWidth = 0
        phraseTextView.layer.cornerRadius = 0
        continueButton.setTitle(l10n(.commonContinue), for: .normal)

        phraseTextView.text = preparedPhrase

        for l in missedWords {
            l.isHighlighted = true
            l.isHidden = false
        }
    }

    private func displayInvalidInfo() {
        explanationLabel.isHidden = true
        noteLabel.isHidden = true
        invalidPassphaseWarningLabel.isHidden = false
        phraseTextView.textColor = UIColor.localRed.withAlphaComponent(0.8)
        phraseTextView.layer.borderColor = UIColor.localRed.cgColor
        phraseTextView.layer.borderWidth = 2
        phraseTextView.layer.cornerRadius = 10
        continueButton.setTitle("Try again", for: .normal)

        for l in missedWords {
            l.isHidden = true
        }
    }

    private func checkCorrectOrder(_ result: String) -> Bool {
        return  sha256Reference == result.sha256()
    }

    @objc func onTapWord(_ sender: UITapGestureRecognizer) {
        guard let label = (sender.view as? UILabel) else { return }
        guard let word = label.text else { return }

        let check = label.isHighlighted
        if check {
            if insertWordToNextFreePlace(word) {
                label.isHighlighted = false
            }
        } else {
            if removeInsertedWord(word) {
                label.isHighlighted = true
            }
        }
    }

    private func showWarningDialog() {
        let alert = AlertController(title: EXAAppInfoService.appTitle, message: l10n(.skipVerifyPassNote), preferredStyle: .alert)
        alert.visualStyle = EXAAlertVisualStyle(alertStyle: .alert)
        let OKAction = AlertAction(title: l10n(.commonOk), style: .destructive, handler: { [weak self]
            (action) -> Void in
            if let wSelf = self {
                EXAAppNavigationDispatcher.sharedInstance.nextNavigationStep(wSelf.navigationController, step: wSelf.selectNextStep())
            }
        })

        let cancelAction = AlertAction(title: l10n(.commonCancel), style: .preferred, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true)
    }

    private func insertWordToNextFreePlace(_ word: String) -> Bool {
        guard let range = phraseTextView.text.range(of: "_______") else { return false }
        phraseTextView.text.replaceSubrange(range, with: word)

        return true
    }

    private func removeInsertedWord(_ word: String) -> Bool {
        // TODO: remove only inserted word (check for duplicate maybe)
        guard let range = phraseTextView.text.range(of: word) else { return false }
        phraseTextView.text.replaceSubrange(range, with: "_______")

        return true
    }
}

