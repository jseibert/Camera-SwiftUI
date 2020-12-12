//
//  ContentView.swift
//  SwiftCamera
//
//  Created by Rolando Rodriguez on 10/15/20.
//

import Foundation
import Combine
import AVFoundation

public final class Camera: ObservableObject {
    private let service = CameraService()

    @Published public var photo: Photo!
    @Published public var showAlertError = false
    @Published public var isFlashOn = false
    @Published public var willCapturePhoto = false

    public var alertError: AlertError!
    public var session: AVCaptureSession

    private var subscriptions = Set<AnyCancellable>()
    private var isConfigured = false

    public init() {
        self.session = service.session

        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)

        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)

        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)

        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
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
}
