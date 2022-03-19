//
//  QRScannerView.swift
//
//  Created by Daniil Kabachuk on 22.01.2021.
//

import UIKit
import AVFoundation

final class QRScannerView: UIView {
    
    // MARK: - Private Properties

    private let metadataQueue = DispatchQueue(label: Constants.metadataQueueLabel)
    private let videoDataQueue = DispatchQueue(label: Constants.videoDataQueueLabel)
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var focusImageView = UIImageView()
    private var metadataOutput = AVCaptureMetadataOutput()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    
    private var metadataOutputEnable = false
    private var videoDataOutputEnable = false
    
    private weak var delegate: QRScannerViewDelegate?
    
    private var focusImage: UIImage?
    private var animationDuration: Double = Constants.defaultAnimationDuration
    
    private enum Constants {
        static let metadataQueueLabel: String = "metadata.queue"
        static let videoDataQueueLabel: String = "videoData.queue"
        static let defaultAnimationDuration: Double = 0.5
        static let focusImageViewWidthCoeff: CGFloat = 0.618
        static let focusImageViewCgRectXCoeff: CGFloat = 0.191
        static let focusImageViewCgRectYCoeff: CGFloat = 0.251
    }
    
    // MARK: - Lifecycle

    deinit {
        setTorchActive(isOn: false)
        focusImageView.removeFromSuperview()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        removePreviewLayer()
    }
    
    // MARK: - Public Methods

    func configure(delegate: QRScannerViewDelegate, input: InputOptions = .default) {
        self.delegate = delegate
        self.focusImage = input.focusImage

        if let animationDuration = input.animationDuration {
            self.animationDuration = animationDuration
        }
        
        configureSession()
        addPreviewLayer()
        setupFocusImageView()
    }
    
    func startRunning() {
        guard isAuthorized(), !session.isRunning else { return }
        videoDataOutputEnable = false
        metadataOutputEnable = true
        metadataQueue.async { [weak session] in
            session?.startRunning()
        }
    }
    
    func setTorchActive(isOn: Bool) {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              videoDevice.hasTorch, videoDevice.isTorchAvailable,
              (metadataOutputEnable || videoDataOutputEnable) else { return }
        try? videoDevice.lockForConfiguration()
        
        if videoDevice.torchMode == .on, isOn {
            videoDevice.torchMode = .off
            delegate?.setTorchImage(with: .off)
        } else {
            videoDevice.torchMode = isOn ? .on : .off
            delegate?.setTorchImage(with: isOn ? .on : .off)
        }
        
        videoDevice.unlockForConfiguration()
    }
    
    func stopScanning() {
        focusImageView.removeScanningIndicator()
    }
    
    func rescan() {
        guard isAuthorized() else { return }
        focusImageView.removeFromSuperview()
        setupFocusImageView()
        videoDataOutputEnable = false
        metadataOutputEnable = true
    }
    
    // MARK: - Private Methods
    
    private func isAuthorized() -> Bool {
        authorizationStatus() == .authorized
    }
    
    private func authorizationStatus() -> AuthorizationStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            failure(.unauthorized(.notDetermined))
            return .notDetermined
        case .denied:
            failure(.unauthorized(.denied))
            return .restrictedOrDenied
        case .restricted:
            failure(.unauthorized(.restricted))
            return .restrictedOrDenied
        default:
            return .restrictedOrDenied
        }
    }
    
    private func configureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            failure(.deviceFailure(.videoUnavailable))
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            failure(.deviceFailure(.inputInvalid))
            return
        }
        
        guard session.canAddOutput(metadataOutput) else {
            failure(.deviceFailure(.metadataOutputFailure))
            return
        }
        
        guard session.canAddOutput(videoDataOutput) else {
            failure(.deviceFailure(.videoDataOutputFailure))
            return
        }
        
        session.beginConfiguration()
        session.addInput(videoInput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        session.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = [.qr]
        
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        session.addOutput(videoDataOutput)
        
        session.commitConfiguration()
        
        if authorizationStatus() == .notDetermined {
            videoDataOutputEnable = false
            metadataOutputEnable = true
            metadataQueue.async { [weak session] in
                session?.startRunning()
            }
        }
    }
    
    private func setupFocusImageView() {
        let width = bounds.width * Constants.focusImageViewWidthCoeff
        let cgRectX = bounds.width * Constants.focusImageViewCgRectXCoeff
        let cgRectY = bounds.height * Constants.focusImageViewCgRectYCoeff
        focusImageView = UIImageView(frame: CGRect(x: cgRectX, y: cgRectY, width: width, height: width))
        focusImageView.image = focusImage ?? Resources.Images.QRScanner.focus.image
        addSubview(focusImageView)
    }
    
    private func addPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds
        layer.addSublayer(previewLayer)
        
        self.previewLayer = previewLayer
    }
    
    private func stopRunning() {
        guard session.isRunning else { return }
        
        videoDataQueue.async { [weak session] in
            session?.stopRunning()
        }
        metadataOutputEnable = false
        videoDataOutputEnable = false
    }
    
    private func removePreviewLayer() {
        previewLayer?.removeFromSuperlayer()
    }
    
    private func failure(_ error: QRScannerError) {
        delegate?.qrScannerView(self, didFailure: error)
    }
    
    private func success(_ code: String) {
        delegate?.qrScannerView(self, didSuccess: code)
    }
}

// MARK: - Models

extension QRScannerView {
    private enum AuthorizationStatus {
        case authorized
        case notDetermined
        case restrictedOrDenied
    }
    
    struct InputOptions {
        let focusImage: UIImage?
        let animationDuration: Double?
        
        static var `default`: InputOptions {
            return .init(focusImage: nil,
                         animationDuration: nil)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard metadataOutputEnable,
              let metadataObject = metadataObjects.first,
              let readableObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = readableObject.stringValue else { return }

        metadataOutputEnable = false
        videoDataOutputEnable = true
        
        DispatchQueue.main.async {
            self.focusImageView.addScanningIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.setTorchActive(isOn: false)
                self.success(stringValue)
            }
        }
    }
}
