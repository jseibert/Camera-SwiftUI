//
//  ContentView.swift
//  SwiftCamera
//
//  Created by Rolando Rodriguez on 10/15/20.
//

import Foundation
import Combine
import AVFoundation

public final class Camera: ObservableObject, CameraServiceDelegate {
    private let service = CameraService()

    @Published public var photo: Photo?
    @Published public var qrCode: String?
    @Published public var showAlertError = false
    @Published public var isFlashOn = false
    @Published public var isCapturing = false

    public var alertError: AlertError!
    public var session: AVCaptureSession {
        return service.session
    }

    private var subscriptions = Set<AnyCancellable>()
    private var isConfigured = false

    public init() {
        service.delegate = self

        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)

        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
    }

    public func start() {
        guard !isConfigured else {
            service.start()
            return
        }

        service.checkForPermissions()
        service.configure()
        self.isConfigured = true

        service.start()
    }

    public func stop() {
        service.stop()
    }

    public func capturePhoto() {
        service.capturePhoto()
    }

    public func flipCamera() {
        service.changeCamera()
    }

    public func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }

    public func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }

    // MARK: - CameraServiceDelegate

    func willCapturePhoto() {
        self.isCapturing = true
    }

    func didCapturePhoto(_ photo: Photo) {
        self.isCapturing = false
        self.photo = photo
    }

    func didFailToCapturePhoto() {
        self.isCapturing = false
    }

    func photoCaptureIsPending(_ pending: Bool) {
        // TODO: Not implemented
    }

    func didDetectQRCode(code: String) {
        self.qrCode = code
    }
}
