//
//  XboxButton.swift
//  ZwiftControllerPlugin
//
//  Created by Barna Nemeth on 12/11/2023.
//

import Foundation

enum XboxButton: CaseIterable {
    case a
    case b
    case y
    case left
    case up
    case right
    case down
    case leftBumper
    case rightBumper

    var hasAnalogInput: Bool {
        switch self {
        case .left, .right, .up, .down: return true
        default: return false
        }
    }
}
