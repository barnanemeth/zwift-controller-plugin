//
//  XboxButtonPress.swift
//  ZwiftControllerPlugin
//
//  Created by Barna Nemeth on 12/11/2023.
//

import Foundation
import KeySender

struct XboxButtonPress: CustomStringConvertible {

    // MARK: Properties

    let button: XboxButton
    let isPressed: Bool

    var mappedKey: KeyEvent.Key {
        switch button {
        case .a: return .return
        case .b: return .escape
        case .y: return .tab
        case .left: return .leftArrow
        case .up: return .upArrow
        case .right: return .rightArrow
        case .down: return .downArrow
        case .leftBumper: return .pageDown
        case .rightBumper: return .pageUp
        }
    }
    var description: String {
        switch button {
        case .a: return "A - \(isPressed ? "Pressed" : "Unpressed")"
        case .b: return "B - \(isPressed ? "Pressed" : "Unpressed")"
        case .y: return "Y - \(isPressed ? "Pressed" : "Unpressed")"
        case .left: return "Left - \(isPressed ? "Pressed" : "Unpressed")"
        case .up: return "Up - \(isPressed ? "Pressed" : "Unpressed")"
        case .right: return "Right - \(isPressed ? "Pressed" : "Unpressed")"
        case .down: return "Down - \(isPressed ? "Pressed" : "Unpressed")"
        case .leftBumper: return "Left Bumper - \(isPressed ? "Pressed" : "Unpressed")"
        case .rightBumper: return "Right Bumper - \(isPressed ? "Pressed" : "Unpressed")"
        }
    }

    // MARK: Init

    init(button: XboxButton, isPressed: Bool) {
        self.button = button
        self.isPressed = isPressed
    }
}
