//
//  LayoutSize.swift
//  MoxiuWidget
//
//  Created by Hui Wang on 2020/11/16.
//

import Foundation

public enum LayoutSizeType: UInt8, Codable {
    case unknown = 0
    case small
    case medium
    case large
    case all = 0xFF
}

public enum AbilityType: Int, Codable {
    case unknown = 0
    case app
    case time
    case weather
    case counter
    case calendar
}
