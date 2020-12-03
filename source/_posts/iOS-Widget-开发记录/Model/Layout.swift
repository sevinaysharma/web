//
//  Layout.swift
//  MoxiuWidget
//
//  Created by Hui Wang on 2020/11/16.
//

import Foundation
import CoreGraphics

private let infos = NSArray(contentsOf: Bundle.main.url(forResource: "WallpaperCut", withExtension: "plist")!)! as! Array<Dictionary<String, AnyObject>>

public final class Layout: Codable {
    public let meta: LayoutMeta
    
    public let theme: String
    public var displayName: String = ""
    public var children: [Element] = []
    
    public var isDarkWallpaper: Bool = false
    
    public var baseURL: URL?
    
    public var bgFileFullName: String?
    
    public init(withType t: LayoutSizeType, identifier id: String, theme _theme: String, screenWidth: Int, screenHeight: Int, screenScale scale: CGFloat) {
        theme = _theme
        
        meta = LayoutMeta(type: t, identifier: id, screenWidth: screenWidth, screenHeight: screenHeight, screenScale: scale)
    }
    
    public func addElement(_ e: Element) {
        if e.meta.limit.layout[0] == .all || e.meta.limit.layout.contains(where: { (l) -> Bool in
            l == self.meta.type
        }) {
            children.append(e)
        }
    }
}

public final class LayoutMeta: Codable {
    public let type: LayoutSizeType
    public let identifier: String
    
    public let widgetPixelWidth: Int
    public let widgetPixelHeight: Int
    public let widgetOriginXPixel: Int
    public let widgetOriginYPixel: Int
    public let screenScale: CGFloat
    
    public init(type t: LayoutSizeType, identifier id: String, screenWidth: Int, screenHeight: Int, screenScale scale: CGFloat) {
        type = t
        identifier = id
        screenScale = scale
        
        var wallpaperCutInfo: [String: AnyObject] = [:]
        let identifiefr = "\(Int(CGFloat(screenWidth) * scale))x\(Int(CGFloat(screenHeight) * scale))"
        for item in infos {
            if (item["pixelSize"] as! String) == identifiefr {
                wallpaperCutInfo = item
                break
            }
        }
        if wallpaperCutInfo.count > 0 {
            switch t {
            case .large:
                widgetPixelWidth = wallpaperCutInfo["largeWidth"] as! Int
                widgetPixelHeight = wallpaperCutInfo["largeHeight"] as! Int
            case .medium:
                widgetPixelWidth = wallpaperCutInfo["mediumWidth"] as! Int
                widgetPixelHeight = wallpaperCutInfo["mediumHeight"] as! Int
            default:
                widgetPixelWidth = wallpaperCutInfo["smallWidth"] as! Int
                widgetPixelHeight = wallpaperCutInfo["smallHeight"] as! Int
            }
            
            widgetOriginXPixel = wallpaperCutInfo["x1"] as! Int
            widgetOriginYPixel = wallpaperCutInfo["y1"] as! Int
        } else {
            widgetPixelWidth = 0
            widgetPixelHeight = 0
            widgetOriginXPixel = 0
            widgetOriginYPixel = 0
        }
    }
}
