import AppKit

public struct CritterRenderer {
    public init() {}

    public func color(for ink: SpriteInk) -> NSColor {
        func c(_ r: Double, _ g: Double, _ b: Double) -> NSColor {
            NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
        }
        switch ink {
        case .body:    return c(1.0, 0.494, 0.0)
        case .eye:     return .black
        case .yellow:  return c(1.0, 0.949, 0.0)
        case .red:     return c(0.929, 0.110, 0.141)
        case .blue:    return c(0.184, 0.212, 0.600)
        case .white:   return .white
        case .green:   return c(0.133, 0.694, 0.298)
        case .hatBlue: return c(0.302, 0.427, 0.953)
        case .brown:   return c(0.612, 0.353, 0.235)
        }
    }

    public var dimension: Int { CritterSprite.dim }

    public func image(outfit: Outfit, spending: Bool = false,
                      size: CGFloat = 20) -> NSImage {
        NSImage(size: NSSize(width: size, height: size),
                flipped: false) { _ in
            self.drawCritter(size: size, outfit: outfit, spending: spending)
            return true
        }
    }

    // Square-grid invariant: dim rows of dim chars for every grid.
    public func gridsAreSquare() -> Bool {
        let n = CritterSprite.dim
        func ok(_ rows: [String]) -> Bool {
            rows.count == n && rows.allSatisfy { $0.count == n }
        }
        guard ok(CritterSprite.base) else { return false }
        for o in Outfit.allCases where CritterSprite.outfits[o] != nil {
            if !ok(CritterSprite.outfits[o]!.rows) { return false }
        }
        return ok(CritterSprite.moneyBag.rows)
    }

    public func hasOutfit(_ o: Outfit) -> Bool {
        CritterSprite.outfits[o] != nil
    }

    private func drawCritter(size s: CGFloat, outfit: Outfit,
                             spending: Bool) {
        NSGraphicsContext.current?.shouldAntialias = false
        let n = CGFloat(CritterSprite.dim)
        let cell = max(1, (s / n).rounded(.down))
        let offset = ((s - cell * n) / 2).rounded(.down)
        paint(CritterSprite.base, cell: cell, offset: offset) { ch in
            ch == "K" ? .black
                : (ch == "B" ? self.color(for: .body) : nil)
        }
        overlay(CritterSprite.outfits[outfit], cell: cell, offset: offset)
        if spending {
            overlay(CritterSprite.moneyBag, cell: cell, offset: offset)
        }
    }

    private func overlay(_ o: OutfitSprite?, cell: CGFloat,
                         offset: CGFloat) {
        guard let o = o else { return }
        paint(o.rows, cell: cell, offset: offset) { ch in
            o.ink[ch].map { self.color(for: $0) }
        }
    }

    private func paint(_ grid: [String], cell: CGFloat, offset: CGFloat,
                       color: (Character) -> NSColor?) {
        let n = CritterSprite.dim
        for (r, row) in grid.enumerated() {
            for (col, ch) in row.enumerated() {
                guard let fill = color(ch) else { continue }
                fill.setFill()
                let x = offset + CGFloat(col) * cell
                let y = offset + CGFloat(n - 1 - r) * cell
                NSBezierPath(rect: NSRect(x: x, y: y,
                    width: cell, height: cell)).fill()
            }
        }
    }
}
