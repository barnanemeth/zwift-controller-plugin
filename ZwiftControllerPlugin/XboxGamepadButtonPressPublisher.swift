//
//  XboxGamepadButtonPressPublisher.swift
//  ZwiftControllerPlugin
//
//  Created by Barna Nemeth on 12/11/2023.
//

import Foundation
import Combine
import GameController

final class XboxGamepadButtonPressPublisher: Publisher {

    // MARK: Typealiases

    typealias Output = XboxButtonPress
    typealias Failure = Never

    // MARK: Private properties

    private let xboxGampead: GCXboxGamepad

    // MARK: Init

    init(xboxGamepad: GCXboxGamepad) {
        self.xboxGampead = xboxGamepad
    }

    // MARK: Publisher

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, XboxButtonPress == S.Input {
        let subscription = XboxGamepadButtonPressSubscription(subscriber: subscriber, xboxGamepad: xboxGampead)
        subscriber.receive(subscription: subscription)
    }
}

final private class XboxGamepadButtonPressSubscription<S: Subscriber> where S.Input == XboxButtonPress, S.Failure == Never {

    // MARK: Constants

    private let analogThreshold: Float = 0.5

    // MARK: Private properties

    private let subscriber: S
    private let xboxGampead: GCXboxGamepad

    private var wasLeftPressed = true
    private var wasRightPressed = true
    private var wasUpPressed = true
    private var wasDownPressed = true

    // MARK: Init

    init(subscriber: S, xboxGamepad: GCXboxGamepad) {
        self.subscriber = subscriber
        self.xboxGampead = xboxGamepad
    }
}

// MARK: - Subscription

extension XboxGamepadButtonPressSubscription: Subscription {
    func request(_ demand: Subscribers.Demand) {
        setupHandlers()
    }

    func cancel() {
        destroyHandlers()
    }
}

// MARK: - Helpers

extension XboxGamepadButtonPressSubscription {
    private func applyButtonValueChangesHandler(_ handler: GCControllerButtonValueChangedHandler?, 
                                                for button: XboxButton) {
        switch button {
        case .a: xboxGampead.buttonA.pressedChangedHandler = handler
        case .b: xboxGampead.buttonB.pressedChangedHandler = handler
        case .y: xboxGampead.buttonY.pressedChangedHandler = handler
        case .left: xboxGampead.dpad.left.pressedChangedHandler = handler
        case .up: xboxGampead.dpad.up.pressedChangedHandler = handler
        case .right: xboxGampead.dpad.right.pressedChangedHandler = handler
        case .down: xboxGampead.dpad.down.pressedChangedHandler = handler
        case .leftBumper: xboxGampead.leftShoulder.pressedChangedHandler = handler
        case .rightBumper: xboxGampead.rightShoulder.pressedChangedHandler = handler
        }
    }

    private func getButtonValueChangedHandler(for button: XboxButton) -> GCControllerButtonValueChangedHandler {
        { [weak self] _, _, isPressed in self?.sendPress(XboxButtonPress(button: button, isPressed: isPressed)) }
    }

    private func setupHandlers() {
        XboxButton.allCases.forEach { button in
            let handler = getButtonValueChangedHandler(for: button)
            applyButtonValueChangesHandler(handler, for: button)
        }

        xboxGampead.leftThumbstick.valueChangedHandler = { [weak self] _, xAxis, yAxis in
            self?.handleThumbstickInput(xValue: xAxis, yValue: yAxis)
        }
    }

    private func destroyHandlers() {
        XboxButton.allCases.forEach { applyButtonValueChangesHandler(nil, for: $0) }
        xboxGampead.leftThumbstick.valueChangedHandler = nil
    }

    private func handleThumbstickInput(xValue: Float, yValue: Float) {
        // Threshold for considering the thumbstick as pressed in a direction

        // Check for left direction
        let isLeftPressed = xValue < -analogThreshold
        if isLeftPressed != wasLeftPressed {
            if isLeftPressed {
                sendPress(XboxButtonPress(button: .left, isPressed: true))
            } else {
                sendPress(XboxButtonPress(button: .left, isPressed: false))
            }
            wasLeftPressed = isLeftPressed
        }

        // Check for right direction
        let isRightPressed = xValue > analogThreshold
        if isRightPressed != wasRightPressed {
            if isRightPressed {
                sendPress(XboxButtonPress(button: .right, isPressed: true))
            } else {
                sendPress(XboxButtonPress(button: .right, isPressed: false))
            }
            wasRightPressed = isRightPressed
        }

        // Check for up direction
        let isUpPressed = yValue < analogThreshold
        if isUpPressed != wasUpPressed {
            if isUpPressed {
                sendPress(XboxButtonPress(button: .up, isPressed: true))
            } else {
                sendPress(XboxButtonPress(button: .up, isPressed: false))
            }
            wasUpPressed = isUpPressed
        }

        // Check for down direction
        let isDownPressed = yValue > -analogThreshold
        if isDownPressed != wasDownPressed {
            if isDownPressed {
                sendPress(XboxButtonPress(button: .down, isPressed: true))
            } else {
                sendPress(XboxButtonPress(button: .down, isPressed: false))
            }
            wasDownPressed = isDownPressed
        }
    }

    private func sendPress(_ press: XboxButtonPress) {
        _ = subscriber.receive(press)
    }
}
