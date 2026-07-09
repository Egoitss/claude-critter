import AppKit

// Heart + horizontal usage bar + NN% digits, drawn as one image to sit
// below the critter. Logical pixels are "u"-sized; the strip is 7u tall.
public struct GaugeRenderer {
    public init() {}

    // "50%" for 0.5; clamped to 0...1.
    public func percentText(_ usage: Double) -> String {
        let p = Int((min(max(usage, 0), 1) * 100).rounded())
        return "\(p)%"
    }

    public func image(usage: Double, fill: NSColor,
                      width: CGFloat, u: CGFloat) -> NSImage {
        let size = NSSize(width: width, height: 7 * u)
        return NSImage(size: size, flipped: false) { _ in
            self.draw(usage: usage, fill: fill, width: width, u: u)
            return true
        }
    }

    // Blit a '#'-bitmap at (x,y) bottom-left, one cell = u px.
    private func blit(_ bmp: [String], x: CGFloat, y: CGFloat,
                      u: CGFloat, color: NSColor) {
        color.setFill()
        let h = bmp.count
        for (r, row) in bmp.enumerated() {
            for (c, ch) in row.enumerated() where ch == "#" {
                let px = x + CGFloat(c) * u
                let py = y + CGFloat(h - 1 - r) * u
                NSBezierPath(rect: NSRect(x: px, y: py,
                    width: u, height: u)).fill()
            }
        }
    }

    private func draw(usage f: Double, fill: NSColor,
                      width: CGFloat, u: CGFloat) {
        NSGraphicsContext.current?.shouldAntialias = false
        let red = NSColor(srgbRed: 0.929, green: 0.11,
                          blue: 0.141, alpha: 1)
        let ink = NSColor(srgbRed: 0.15, green: 0.15,
                          blue: 0.17, alpha: 1)
        blit(PixelFont.heart, x: 0, y: u, u: u, color: red)
        let text = PixelFont.text(percentText(f))
        let textW = CGFloat(text.first?.count ?? 0) * u
        blit(text, x: width - textW, y: u, u: u, color: ink)
        let barX = 6 * u
        let barR = width - textW - u
        let barY = 1.5 * u, barH = 4 * u
        ink.setFill()
        NSBezierPath(rect: NSRect(x: barX, y: barY,
            width: max(0, barR - barX), height: barH)).fill()
        NSColor.white.setFill()
        let inX = barX + u, inY = barY + u
        let inW = max(0, (barR - barX) - 2 * u)
        let inH = barH - 2 * u
        NSBezierPath(rect: NSRect(x: inX, y: inY,
            width: inW, height: inH)).fill()
        fill.setFill()
        let frac = CGFloat(min(max(f, 0), 1))
        NSBezierPath(rect: NSRect(x: inX, y: inY,
            width: inW * frac, height: inH)).fill()
    }
}
