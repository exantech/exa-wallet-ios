//
//  AddressScannerViewController.swift
//  EXAWallet
//
//  Created by Igor Efremov on 14/02/2018.
//  Copyright © 2018 Exantech. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

protocol AddressScannerActionDelegate: class {
    func onAddressRecognized(_ address: String)
}

class AddressScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hideInfoMessage: Bool = false
    weak var actionDelegate: AddressScannerActionDelegate?
    
    private var infoStaticLabel: UILabel = UILabel(l10n(.scanCameraUnavailable),
            textColor: UIColor.titleLabelColor, font: UIFont.systemFont(ofSize: 14.0))

    override func loadView() {
        super.loadView()
        
        setupCamera()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = l10n(.scanTitle)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: l10n(.commonClose),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(onCloseTap))
        self.view.addSubview(infoStaticLabel)
        applyStyles()
        applySizes()
        
        self.view.addTapTouch(self, action: #selector(onTap))
        self.view.backgroundColor = UIColor.screenBackgroundColor
    }

    override func applyStyles() {
        infoStaticLabel.textAlignment = .center
        infoStaticLabel.numberOfLines = 0
        infoStaticLabel.isHidden = hideInfoMessage
    }
    
    private func applySizes() {
        infoStaticLabel.snp.makeConstraints{ (make) in
            make.width.equalToSuperview()
            make.height.equalTo(70)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        do {
            try videoCaptureDevice.lockForConfiguration()
            if videoCaptureDevice.isAutoFocusRangeRestrictionSupported {
                videoCaptureDevice.autoFocusRangeRestriction = .near
            }
            videoCaptureDevice.unlockForConfiguration()
        } catch {
            print("Could not configure video capture device: \(error)")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .hd1280x720
            captureSession?.addInput(videoInput)
            
            hideInfoMessage = true
        } catch {
            print("Could not create video input: \(error)")
            return
        }
        
        if let theCaptureSession = captureSession {
            previewLayer = AVCaptureVideoPreviewLayer(session: theCaptureSession)
            previewLayer?.frame = self.view.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            self.view.layer.insertSublayer(previewLayer!, at: 0)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
    }
    
    func startScanningQR() {
        captureSession?.startRunning()
    }
    
    // AVCaptureMetadataOutputObjectsDelegate implementation
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("metadataOutput CALL")
        
        for metadataObject in metadataObjects {
            if !metadataObject.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                continue
            }
            
            if let readableObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {
                if let theStringValue = readableObject.stringValue {
                    addressFoundAndRecognized(theStringValue)
                    break
                }
            }
        }
    }
    
    private func addressFoundAndRecognized(_ address: String) {
        captureSession?.stopRunning()
        actionDelegate?.onAddressRecognized(address)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onCloseTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
