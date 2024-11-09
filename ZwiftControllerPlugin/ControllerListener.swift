//
//  ControllerListener.swift
//  ZwiftControllerPlugin
//
//  Created by Barna Nemeth on 12/11/2023.
//

import Foundation
import GameController
import Combine
import KeySender

final class ControllerListener {

    // MARK: Constants

    private enum Constant {
        static let zwiftApplicationName = "ZwiftAppSilicon"
    }

    // MARK: Private properties

    private var cancellables = Set<AnyCancellable>()
    private let notificationCenter = NotificationCenter.default
    private let workspace = NSWorkspace.shared
    @Published var currentController: GCController?

    // MARK: Init

    init() {
        GCController.shouldMonitorBackgroundEvents = true
    }
}

// MARK: - Public methods

extension ControllerListener {
    func start() {
        guard cancellables.isEmpty else { return }
        setupPublishers()
    }

    func stop() {
        cancellables.removeAll()
    }
}

// MARK: - Private methods

extension ControllerListener {
    private func setupPublishers() {
        let didConnectPublisher = notificationCenter.publisher(for: Notification.Name.GCControllerDidConnect)
        let didDisconnectPublisher = notificationCenter.publisher(for: Notification.Name.GCControllerDidDisconnect)

        Publishers.Merge(didConnectPublisher, didDisconnectPublisher)
            .map { _ in GCController.current }
            .handleEvents(receiveOutput: { controller in
                if let controller {
                    NSLog("Controller connected", controller)
                } else {
                    NSLog("No controller found")
                }
            })
            .compactMap { $0?.extendedGamepad as? GCXboxGamepad }
            .map { XboxGamepadButtonPressPublisher(xboxGamepad: $0) }
            .switchToLatest()
            .filter { $0.isPressed }
            .handleEvents(receiveOutput: { NSLog($0.description) })
            .sink { [unowned self] in self.handleButtonPress($0) }
            .store(in: &cancellables)
    }

    private func handleButtonPress(_ buttonPress: XboxButtonPress) {
        guard buttonPress.isPressed else { return }
        let sender = KeySender(key: buttonPress.mappedKey)
        try? sender.send(to: Constant.zwiftApplicationName)
    }
}
