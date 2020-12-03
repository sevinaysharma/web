//
//  LayoutInfoWrapper.swift
//  MoxiuWidget
//
//  Created by Hui Wang on 2020/11/18.
//

import Foundation

public final class LayoutInfoWrapper: Codable {
    public var identifier: String
    public var name: String
    public var jsonString: String
    public var createdDate: Date = Date()
    
    public init(identifier id: String, name n: String, json: String) {
        identifier = id
        name = n
        jsonString = json
    }
}
