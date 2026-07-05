import AppKit

public struct CritterRenderer {
    public init() {}

    // Body is terracotta up top with pale grey rising from the feet as
    // usage climbs — a gauge. Eyes are black; outfit accent draws on top.
    public var bodyColor: NSColor {
        NSColor(srgbRed: 0.79, green: 0.42, blue: 0.30, alpha: 1)
    }
    public var depletedColor: NSColor {          // pale grey, "used up"
        NSColor(srgbRed: 0.62, green: 0.60, blue: 0.58, alpha: 1)
    }
    public var moneyGold: NSColor {              // money bag
        NSColor(srgbRed: 0.92, green: 0.72, blue: 0.16, alpha: 1)
    }
    public var moneyDark: NSColor {              // the $ mark
        NSColor(srgbRed: 0.35, green: 0.22, blue: 0.05, alpha: 1)
    }

    public func outfitAccent(_ o: Outfit) -> NSColor {
        switch o {
        case .crown: return .systemYellow
        case .headphones: return .systemBlue
        case .headband: return .systemGreen
        case .wizardHat: return .systemTeal
        }
    }

    // usage 0...1: fraction of the body (from the feet up) shown depleted.
    public func image(usage: Double, outfit: Outfit, spending: Bool = false,
                      size: CGFloat = 18) -> NSImage {
        let f = min(max(usage, 0), 1)
        return NSImage(size: NSSize(width: size, height: size),
                       flipped: false) { _ in
            self.drawCritter(size: size, usage: f, outfit: outfit,
                             spending: spending)
            return true
        }
    }

    private func drawCritter(size s: CGFloat, usage f: Double,
                             outfit: Outfit, spending: Bool) {
        NSGraphicsContext.current?.shouldAntialias = false  // hard pixels
        let n = CGFloat(CritterSprite.dim)
        let cell = max(1, (s / n).rounded(.down))   // integer px/cell
        let offset = ((s - cell * n) / 2).rounded(.down)   // center it
        let grey = greyFromRow(usage: f)
        let body = bodyColor, used = depletedColor
        paint(CritterSprite.base, cell: cell, offset: offset) { r, ch in
            if ch == "K" { return .black }
            if ch == "B" { return r >= grey ? used : body }
            return nil
        }
        if let overlay = CritterSprite.outfits[outfit] {
            let accent = outfitAccent(outfit)
            paint(overlay, cell: cell, offset: offset) { _, ch in
                ch == "A" ? accent : nil
            }
        }
        if spending {
            let gold = moneyGold, dark = moneyDark
            paint(CritterSprite.moneyBag, cell: cell, offset: offset) {
                _, ch in
                ch == "M" ? gold : (ch == "D" ? dark : nil)
            }
        }
    }

    public var bodyRowRange: (Int, Int) { CritterSprite.bodyRowRange }

    // First body row (from the top) that renders depleted, given usage.
    // Grey fills upward from the bottom of the critter.
    public func greyFromRow(usage f: Double) -> Int {
        let (top, bot) = CritterSprite.bodyRowRange
        let span = bot - top + 1
        let greyRows = Int((f * Double(span)).rounded())
        return bot - greyRows + 1
    }

    private func paint(_ grid: [String], cell: CGFloat, offset: CGFloat,
                       color: (Int, Character) -> NSColor?) {
        let n = CritterSprite.dim
        for (r, row) in grid.enumerated() {
            for (c, ch) in row.enumerated() {
                guard let col = color(r, ch) else { continue }
                col.setFill()
                let x = offset + CGFloat(c) * cell
                let y = offset + CGFloat(n - 1 - r) * cell
                NSBezierPath(rect: NSRect(x: x, y: y,
                    width: cell, height: cell)).fill()
            }
        }
    }
}
