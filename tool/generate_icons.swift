// Rebuild the app's code-drawn monogram: swift -module-cache-path /tmp/portfolio-swift-cache tool/generate_icons.swift
import Foundation
import AppKit

let projectRoot = URL(fileURLWithPath: ".").standardizedFileURL
func render(_ relativePath: String, _ size: Int) throws {
    let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: size * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    context.scaleBy(x: CGFloat(size) / 48, y: CGFloat(size) / 48)
    NSColor(red: 8/255, green: 11/255, blue: 20/255, alpha: 1).setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: 48, height: 48)).fill()
    let path = NSBezierPath(roundedRect: NSRect(x: 4, y: 4, width: 40, height: 40), xRadius: 12, yRadius: 12)
    NSGradient(starting: NSColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1), ending: NSColor(red: 34/255, green: 211/255, blue: 238/255, alpha: 1))!.draw(in: path, angle: -45)
    let mark = NSBezierPath()
    mark.move(to: NSPoint(x: 12, y: 32)); mark.line(to: NSPoint(x: 17, y: 24)); mark.line(to: NSPoint(x: 22, y: 32))
    mark.move(to: NSPoint(x: 17, y: 24)); mark.line(to: NSPoint(x: 17, y: 16))
    mark.move(to: NSPoint(x: 27, y: 16)); mark.line(to: NSPoint(x: 27, y: 32)); mark.line(to: NSPoint(x: 37, y: 16)); mark.line(to: NSPoint(x: 37, y: 32))
    mark.lineWidth = 2.5; mark.lineCapStyle = .round; mark.lineJoinStyle = .round
    NSColor.white.setStroke(); mark.stroke()
    NSGraphicsContext.restoreGraphicsState()
    let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
    try bitmap.representation(using: .png, properties: [:])!.write(to: projectRoot.appendingPathComponent(relativePath))
}
for (name, size) in [("web/favicon.png",32), ("web/icons/Icon-192.png",192), ("web/icons/Icon-512.png",512), ("web/icons/Icon-maskable-192.png",192), ("web/icons/Icon-maskable-512.png",512)] { try render(name,size) }
for (density,size) in [("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)] { try render("android/app/src/main/res/mipmap-\(density)/ic_launcher.png",size) }
for folder in ["ios/Runner/Assets.xcassets/AppIcon.appiconset", "macos/Runner/Assets.xcassets/AppIcon.appiconset"] {
    let data = try Data(contentsOf: projectRoot.appendingPathComponent("\(folder)/Contents.json"))
    let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
    for image in json["images"] as! [[String:String]] {
        guard let name = image["filename"], let dimension = image["size"], let scale = image["scale"] else { continue }
        let side = Double(dimension.split(separator: "x")[0])!
        let multiplier = Double(scale.replacingOccurrences(of: "x", with: ""))!
        try render("\(folder)/\(name)", Int(side * multiplier))
    }
}
print("Generated YN launcher icons for Android, iOS, macOS, and web.")
