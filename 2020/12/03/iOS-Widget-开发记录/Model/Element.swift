//
//  Element.swift
//  MoxiuWidget
//
//  Created by Hui Wang on 2020/11/16.
//

import Foundation
import CoreGraphics

public class Element: Codable {
    public let identifier: String
    public let meta: Meta
    public let config: ElementBaseConfig
    
    public init(identifier id: String, meta m: Meta, config c: ElementBaseConfig) {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        identifier = id
        config = ElementBaseConfig.copy(target: c)
        meta = try! decoder.decode(Meta.self, from: encoder.encode(m))
    }
}

extension Element {
    public func convert() -> Self {
        return self as Self
    }
    
    public func copy() -> Self {
        let data = try! JSONEncoder().encode(self)
        return try! JSONDecoder().decode(Self.self, from: data)
    }
}

public class ElementBaseConfig: Codable {
    var x: Int = 0
    var y: Int = 0
    var width: Int = 0
    var height: Int = 0
    
    let bg: String
    let action: String
    
    var title: String = ""
    
    var others: [String: AnyObject] = [:]
    
    enum CodingKeys: String, CodingKey {
        case x
        case y
        case width
        case height
        case bg
        case action
        case title
        case others
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(Int.self, forKey: .x)
        y = try container.decode(Int.self, forKey: .y)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        
        bg = try container.decode(String.self, forKey: .bg)
        action = try container.decode(String.self, forKey: .action)
        title = try container.decode(String.self, forKey: .title)
        
        let jsonString = try container.decode(String.self, forKey: .others)
        others = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as! [String : AnyObject]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(bg, forKey: .bg)
        try container.encode(action, forKey: .action)
        try container.encode(title, forKey: .title)
        
        let jsonData = try JSONSerialization.data(withJSONObject: others, options: .fragmentsAllowed)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        try container.encode(jsonString, forKey: .others)
    }
    
    public init(action a: String, background _bg: String) {
        action = a
        bg = _bg
    }
    
    class func copy(target: ElementBaseConfig) -> ElementBaseConfig {
        let data = try! JSONEncoder().encode(target)
        return try! JSONDecoder().decode(ElementBaseConfig.self, from: data)
    }
}
