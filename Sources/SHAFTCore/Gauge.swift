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

    // Gauge ink. Red heart matches the original design; green marks
    // money; dim marks unknown readings.
    private static let red = NSColor(srgbRed: 0.929, green: 0.11,
                                     blue: 0.141, alpha: 1)
    private static let green = NSColor(srgbRed: 0.216, green: 0.78,
                                       blue: 0.31, alpha: 1)
    private static let dim = NSColor(white: 0.45, alpha: 1)

    /// Legacy session-style entry: used fraction -> remaining %.
    /// Kept so SpritePreview and older callers stay source-stable.
    public func image(usage: Double?, width: CGFloat,
                      u: CGFloat) -> NSImage {
        let reading = GaugeReading(
            icon: .heart,
            text: usage.map { percentText(1 - $0) } ?? "--",
            known: usage != nil)
        return image(reading: reading, width: width, u: u)
    }

    /// Renders one resolved reading as the 7u-tall gauge strip.
    public func image(reading: GaugeReading, width: CGFloat,
                      u: CGFloat) -> NSImage {
        let size = NSSize(width: width, height: 7 * u)
        return NSImage(size: size, flipped: false) { _ in
            self.draw(reading, width: width, u: u)
            return true
        }
    }

    /// Centers icon + 1-cell gap + label in the strip and blits both.
    private func draw(_ r: GaugeReading, width: CGFloat, u: CGFloat) {
        NSGraphicsContext.current?.shouldAntialias = false
        let icon = Self.iconBitmap(r.icon)
        let text = PixelFont.text(r.text)
        let iconW = CGFloat(icon.first?.count ?? 0)
        let textW = CGFloat(text.first?.count ?? 0)
        let groupW = (iconW + 1 + textW) * u
        let x0 = ((width - groupW) / 2).rounded(.down)
        blit(icon, x: x0, y: u, u: u, color: Self.iconColor(r))
        blit(text, x: x0 + (iconW + 1) * u, y: u, u: u,
             color: r.known ? .white : Self.dim)
    }

    /// Bitmap for the reading's icon slot.
    private static func iconBitmap(_ icon: GaugeIcon) -> [String] {
        switch icon {
        case .heart: return PixelFont.heart
        case .weekly: return PixelFont.weekly
        case .dollar: return PixelFont.dollar
        }
    }

    /// Icon ink: red heart, white W, green $; dim when unknown.
    private static func iconColor(_ r: GaugeReading) -> NSColor {
        guard r.known else { return dim }
        switch r.icon {
        case .heart: return red
        case .weekly: return .white
        case .dollar: return green
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
}
