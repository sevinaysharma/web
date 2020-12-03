//
//  AppElement.swift
//  MoxiuWidget
//
//  Created by Hui Wang on 2020/11/16.
//

import Foundation

public final class AppElement: Element {
    
    public convenience init(identifier id: String, config c: AppElementConfig) {
        self.init(identifier: id, meta: Meta(limit: Limit(layout: [.all]), type: .app), config: c)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    private override init(identifier id: String, meta m: Meta, config c: ElementBaseConfig) {
        super.init(identifier: id, meta: m, config: c)
    }
}

public final class AppElementConfig: ElementBaseConfig {
}
