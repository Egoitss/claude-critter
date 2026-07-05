import AppKit

public struct CritterRenderer {
    public init() {}

    public func moodTint(_ m: Mood) -> NSColor {
        switch m {
        case .fresh: return NSColor(srgbRed: 0.79, green: 0.42,
            blue: 0.30, alpha: 1)                 // terracotta
        case .focused: return NSColor(srgbRed: 0.85, green: 0.55,
            blue: 0.20, alpha: 1)
        case .tired: return NSColor(srgbRed: 0.70, green: 0.26,
            blue: 0.09, alpha: 1)
        case .asleep: return NSColor(srgbRed: 0.45, green: 0.40,
            blue: 0.38, alpha: 1)                 // grey, napping
        }
    }

    public func outfitAccent(_ o: Outfit) -> NSColor {
        switch o {
        case .crown: return .systemYellow
        case .headphones: return .systemBlue
        case .headband: return .systemGreen
        case .wizardHat: return .systemTeal
        }
    }

    public func image(mood: Mood, outfit: Outfit,
                      size: CGFloat = 18) -> NSImage {
        let body = moodTint(mood); let accent = outfitAccent(outfit)
        return NSImage(size: NSSize(width: size, height: size),
                       flipped: false) { _ in
            self.drawCritter(size: size, body: body, accent: accent,
                             outfit: outfit)
            return true
        }
    }

    private func drawCritter(size s: CGFloat, body: NSColor,
                             accent: NSColor, outfit: Outfit) {
        let cell = s / CGFloat(CritterSprite.dim)
        paint(CritterSprite.base, cell: cell) {
            $0 == "B" ? body : ($0 == "K" ? .black : nil)
        }
        if let overlay = CritterSprite.outfits[outfit] {
            paint(overlay, cell: cell) { $0 == "A" ? accent : nil }
        }
    }

    private func paint(_ grid: [String], cell: CGFloat,
                       color: (Character) -> NSColor?) {
        let side = cell * CGFloat(CritterSprite.dim)
        for (r, row) in grid.enumerated() {
            for (c, ch) in row.enumerated() {
                guard let col = color(ch) else { continue }
                col.setFill()
                let x = CGFloat(c) * cell
                let y = side - CGFloat(r + 1) * cell
                NSBezierPath(rect: NSRect(x: x, y: y,
                    width: cell, height: cell)).fill()
            }
        }
    }
}
