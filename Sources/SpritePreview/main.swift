import AppKit
import SHAFTCore

// Dev tool: render every outfit to a PNG sprite sheet so the critter can be
// inspected directly. Run: `swift run SpritePreview [outPath]`.
// Default output: ~/Downloads/shaft-preview.png

let renderer = CritterRenderer()
// (label, usage 0...1, outfit). First four show outfits at low usage; the
// last four show the fable critter filling grey from the feet by usage.
let tiles: [(String, Double, Outfit, Bool)] = [
    ("opus", 0.15, .crown, false),
    ("sonnet", 0.15, .headphones, false),
    ("haiku", 0.15, .headband, false),
    ("fable 0%", 0.0, .wizardHat, false),
    ("fable 75%", 0.75, .wizardHat, false),
    ("fable 100%", 1.0, .wizardHat, false),
    ("fable $", 0.3, .wizardHat, true),
]

let tile: CGFloat = 144
let gaugeH = 40
let cols = tiles.count
let w = Int(tile) * cols
let h = Int(tile) + gaugeH

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
let gaugeR = GaugeRenderer()
for (i, t) in tiles.enumerated() {
    renderer.image(outfit: t.2, spending: t.3, size: tile)
        .draw(at: NSPoint(x: CGFloat(i) * tile, y: CGFloat(gaugeH)),
              from: .zero, operation: .sourceOver, fraction: 1)
    let fill = (t.2 == .wizardHat)
        ? renderer.color(for: .yellow) : renderer.color(for: .body)
    gaugeR.image(usage: t.1, fill: fill, width: tile - 16, u: 4)
        .draw(at: NSPoint(x: CGFloat(i) * tile + 8, y: 6),
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
