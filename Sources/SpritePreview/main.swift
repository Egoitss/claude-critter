import AppKit
import SHAFTCore

// Dev tool: render every outfit to a PNG sprite sheet so the critter can be
// inspected directly. Run: `swift run SpritePreview [outPath]`.
// Default output: ~/Downloads/shaft-preview.png

let renderer = CritterRenderer()
let tiles: [(String, Mood, Outfit)] = [
    ("opus", .fresh, .crown),
    ("sonnet", .fresh, .headphones),
    ("haiku", .fresh, .headband),
    ("fable", .fresh, .wizardHat),
    ("fable-tired", .tired, .wizardHat),
    ("fable-asleep", .asleep, .wizardHat),
]

let tile: CGFloat = 144
let cols = tiles.count
let w = Int(tile) * cols
let h = Int(tile)

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
    isPlanar: false, colorSpaceName: .deviceRGB,
    bytesPerRow: 0, bitsPerPixel: 0) else {
    fatalError("could not allocate bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor(white: 0.12, alpha: 1).setFill()            // app-like dark bg
NSRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h)).fill()
for (i, t) in tiles.enumerated() {
    renderer.image(mood: t.1, outfit: t.2, size: tile)
        .draw(at: NSPoint(x: CGFloat(i) * tile, y: 0),
              from: .zero, operation: .sourceOver, fraction: 1)
}
NSGraphicsContext.restoreGraphicsState()

let outPath = CommandLine.arguments.dropFirst().first
    ?? (("~/Downloads/shaft-preview.png" as NSString).expandingTildeInPath)
if let png = rep.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: outPath))
    print("wrote \(outPath) (\(w)x\(h))")
} else {
    print("failed to encode PNG")
}
