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
            self.drawCritter(size: size, body: body, accent: accent)
            return true
        }
    }

    private func drawCritter(size s: CGFloat, body: NSColor,
                             accent: NSColor) {
        body.setFill()                       // body
        NSBezierPath(roundedRect: NSRect(x: s*0.2, y: s*0.16,
            width: s*0.6, height: s*0.56),
            xRadius: s*0.22, yRadius: s*0.22).fill()

        NSBezierPath(rect: NSRect(x: s*0.3, y: s*0.08,   // legs
            width: s*0.1, height: s*0.12)).fill()
        NSBezierPath(rect: NSRect(x: s*0.6, y: s*0.08,
            width: s*0.1, height: s*0.12)).fill()

        NSColor.black.setFill()              // eyes
        let e = s * 0.1
        NSBezierPath(ovalIn: NSRect(x: s*0.36, y: s*0.44,
            width: e, height: e)).fill()
        NSBezierPath(ovalIn: NSRect(x: s*0.54, y: s*0.44,
            width: e, height: e)).fill()

        accent.setFill()                     // outfit hat
        let hat = NSBezierPath()
        hat.move(to: NSPoint(x: s*0.5, y: s*0.86))
        hat.line(to: NSPoint(x: s*0.34, y: s*0.68))
        hat.line(to: NSPoint(x: s*0.66, y: s*0.68))
        hat.close()
        hat.fill()
    }
}
