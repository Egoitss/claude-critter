import AppKit

// Heart + NN% digits, drawn as one image to sit below the critter.
// Logical pixels are "u"-sized; the strip is 7u tall.
public struct GaugeRenderer {
    public init() {}

    // "50%" for 0.5; clamped to 0...1.
    public func percentText(_ usage: Double) -> String {
        let p = Int((min(max(usage, 0), 1) * 100).rounded())
        return "\(p)%"
    }

    public func image(usage: Double, width: CGFloat, u: CGFloat) -> NSImage {
        let size = NSSize(width: width, height: 7 * u)
        return NSImage(size: size, flipped: false) { _ in
            self.draw(usage: usage, width: width, u: u)
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

    private func draw(usage f: Double, width: CGFloat, u: CGFloat) {
        NSGraphicsContext.current?.shouldAntialias = false
        let red = NSColor(srgbRed: 0.929, green: 0.11,
                          blue: 0.141, alpha: 1)
        // show remaining budget (100% - used), not the used amount
        let text = PixelFont.text(percentText(1 - f))
        let textW = CGFloat(text.first?.count ?? 0)
        // center the heart(5) + 1-cell gap + text group in the strip
        let groupW = (6 + textW) * u
        let x0 = ((width - groupW) / 2).rounded(.down)
        blit(PixelFont.heart, x: x0, y: u, u: u, color: red)
        blit(text, x: x0 + 6 * u, y: u, u: u, color: .white)
    }
}
