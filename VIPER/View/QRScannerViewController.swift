//
//  QRScannerViewController.swift
//
//  Created by Daniil Kabachuk on 24/01/2021.
//

import UIKit

final class QRScannerViewController: BaseViewController {
    
    // MARK: - Private Properties

    private lazy var scannerView = QRScannerView(frame: view.bounds)
    private let torchButton = UIButton()
    
    private var bottomButton: UIButton = {
        let button = UIButton()
        button.setImage(Resources.Images.QRScanner.scan.image, for: .normal)
        button.imageEdgeInsets.left = -Constants.bottomButtonImageInset
        button.setTitle(L10n.QRScanner.bottomButtonTitle, for: .normal)
        button.titleLabel?.font = Constants.bottomButtonTitleFont
        button.titleLabel?.textColor = Resources.Colors.General.white.color
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private enum Constants {
        static let bottomButtonImageInset: CGFloat = 12
        static let bottomButtonTitleFont = GenFonts.Inter.regular.font(size: 16)
        static let closeButtonTopConstraint: CGFloat = 11
        static let closeButtonLeftConstraint: CGFloat = 16
        static let torchButtonTopConstraint: CGFloat = 11
        static let bottomButtonBottomConstraint: CGFloat = 17
        static let descriptionLabelFont = GenFonts.Inter.regular.font(size: 15)
        static let descriptionBottomConstraint: CGFloat = 77
        static let descriptionSideConstraint: CGFloat = 24
        static let scannerAnimationDuration: Double = 0.5
    }

    // MARK: - Public Properties

    var presenter: QRScannerPresenterInput!
    
    enum TorchButtonState {
        case on
        case off
    }

    // MARK: - Lifecycle

	override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()        
    }
    
    // MARK: - Private Methods
    
    private func setupButtons() {
        setupCloseButton()
        setupTorchButton()
        setupBottomButton()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton()
        closeButton.setImage(Resources.Images.QRScanner.back.image, for: .normal)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(backButtonTouchUpInside))
        closeButton.addGestureRecognizer(tapAction)
        scannerView.addSubview(closeButton)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: scannerView.safeAreaLayoutGuide.topAnchor,
                                         constant: Constants.closeButtonTopConstraint).isActive = true
        closeButton.leftAnchor.constraint(equalTo: scannerView.leftAnchor,
                                          constant: Constants.closeButtonLeftConstraint).isActive = true
    }
    
    private func setupTorchButton() {
        torchButton.setImage(Resources.Images.QRScanner.torchDisable.image, for: .normal)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(torchButtonTouchUpInside))
        torchButton.addGestureRecognizer(tapAction)
        scannerView.addSubview(torchButton)
        
        torchButton.translatesAutoresizingMaskIntoConstraints = false
        torchButton.topAnchor.constraint(equalTo: scannerView.safeAreaLayoutGuide.topAnchor,
                                         constant: Constants.torchButtonTopConstraint).isActive = true
        torchButton.centerXAnchor.constraint(equalTo: scannerView.centerXAnchor).isActive = true
    }
    
    private func setupBottomButton() {
        scannerView.addSubview(bottomButton)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(backButtonTouchUpInside))
        bottomButton.addGestureRecognizer(tapAction)
        
        bottomButton.bottomAnchor.constraint(equalTo: scannerView.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -Constants.bottomButtonBottomConstraint).isActive = true
        bottomButton.centerXAnchor.constraint(equalTo: scannerView.centerXAnchor).isActive = true
    }
    
    private func setupDescriptionLabel() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = L10n.QRScanner.descriptionTitle
        descriptionLabel.numberOfLines = .zero
        descriptionLabel.font = Constants.descriptionLabelFont
        descriptionLabel.textColor = Resources.Colors.General.white.color
        descriptionLabel.textAlignment = .center
        scannerView.addSubview(descriptionLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.bottomAnchor.constraint(equalTo: bottomButton.topAnchor,
                                                 constant: -Constants.descriptionBottomConstraint).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: scannerView.leftAnchor,
                                               constant: Constants.descriptionSideConstraint).isActive = true
        descriptionLabel.rightAnchor.constraint(equalTo: scannerView.rightAnchor,
                                                constant: -Constants.descriptionSideConstraint).isActive = true
    }
    
    @objc private func backButtonTouchUpInside() {
        presenter.closeScannerView()
    }
    
    @objc private func torchButtonTouchUpInside() {
        scannerView.setTorchActive(isOn: true)
    }
}

// MARK: - QRScannerPresenterOutput

extension QRScannerViewController: QRScannerPresenterOutput {
    func setupUI() {
        view.addSubview(scannerView)
        scannerView.configure(delegate: self,
                              input: QRScannerView.InputOptions(focusImage: Resources.Images.QRScanner.focus.image,
                                                                animationDuration: Constants.scannerAnimationDuration))
        scannerView.startRunning()
        setupButtons()
        setupDescriptionLabel()
    }
    
    func rescan() {
        scannerView.rescan()
    }
    
    func stopScanning() {
        scannerView.stopScanning()
    }
}

// MARK: - QRScannerViewDelegate

extension QRScannerViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        presenter.didSuccessScanning(code)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        presenter.didFailureScanning()
    }
    
    func setTorchImage(with state: TorchButtonState) {
        torchButton.setImage(state == .on
                                ? Resources.Images.QRScanner.torchEnable.image
                                : Resources.Images.QRScanner.torchDisable.image,
                             for: .normal)
    }
}
