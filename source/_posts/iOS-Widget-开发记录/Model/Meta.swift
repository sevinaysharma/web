//
//  Meta.swift
//  MoxiuWidget
//
//  Created by Hui Wang on 2020/11/16.
//

import Foundation

public final class Limit: Codable {
    public let layout: [LayoutSizeType]
    
    public init(layout l: [LayoutSizeType]) {
        layout = l
    }
}

public final class Meta: Codable {
    public let limit: Limit
    public let type: AbilityType
    
    public init(limit l: Limit, type t: AbilityType) {
        limit = l
        type = t
    }
}

