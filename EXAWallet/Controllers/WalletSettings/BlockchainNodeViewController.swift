//
// Created by Igor Efremov on 01/11/2018.
// Copyright (c) 2018 Exantech. All rights reserved.
//

import UIKit
import SnapKit

final class BlockchainNodeViewController: UIViewController {
    private let nodeTextField: EXAHeaderTextFieldView = {
        let tf = EXAHeaderTextFieldView(l10n(.settingsEnterNodeAddress),
                header: l10n(.settingsNodeAddress).capitalizedOnlyFirst)
        tf.textField.keyboardType = .asciiCapable
        return tf
    }()

    private let resetButton: EXAButton = EXAButton(with: l10n(.commonResetToDefault))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func applyStyles() {
        super.applyStyles()
        nodeTextField.applyStyles()
        navigationItem.title = l10n(.settingsNodeAddress)
        view.backgroundColor = UIColor.screenBackgroundColor
    }

    func applyLayout() {
        let offset: CGFloat = 20

        nodeTextField.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(offset)
            make.width.equalToSuperview().inset(offset)
            make.height.equalTo(nodeTextField.defaultHeight)
        }

        resetButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-offset)
            } else {
                make.bottom.equalToSuperview().offset(-offset)
            }

            make.width.equalToSuperview().inset(offset)
            make.height.equalTo(EXAButton.defaultHeight)
        }

        nodeTextField.applyLayout()
    }

    func applyCurrentValues() {
        nodeTextField.textField.text = AppState.sharedInstance.settings.environment.nodes.currentNode
    }

    func applyDefaultValues() {
        nodeTextField.textField.text = AppState.sharedInstance.settings.environment.nodes.defaultNode
    }

    @objc func onTapResetToDefaults() {
        applyDefaultValues()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nodeAddress = self.nodeTextField.text

        if let theURL = URL(string: nodeAddress) {
            AppState.sharedInstance.settings.environment.nodes.currentNode = theURL.absoluteString
        }
    }
}

private extension BlockchainNodeViewController {

    func addSubviews() {
        let allSubviews = [nodeTextField, resetButton]
        view.addMultipleSubviews(with: allSubviews)
    }

    func setupView() {
        addSubviews()
        applyStyles()
        applyLayout()
        applyCurrentValues()
        addEvents()
    }

    func addEvents() {
        view.addTapTouch(self, action: #selector(switchFirstResponder))
        resetButton.addTarget(self, action: #selector(onTapResetToDefaults), for: .touchUpInside)
    }

    @objc func switchFirstResponder() {
        _ = nodeTextField.resignFirstResponder()
        view.becomeFirstResponder()
    }
}
