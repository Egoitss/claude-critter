import AppKit

// Renders the critter by compositing the hand-drawn pixel art shipped in
// Resources/: a base body PNG, an outfit overlay per model, and an optional
// money-bag overlay. Source art is 128x128; drawing uses nearest-neighbor
// (no interpolation) so pixels stay crisp at any scale.
public struct CritterRenderer {
    public init() {}

    // Native pixel dimension of the source art (square).
    public static let artSize: CGFloat = 128

    private static var cache: [String: NSImage] = [:]

    private static func asset(_ name: String) -> NSImage? {
        if let hit = cache[name] { return hit }
        guard let url = Bundle.module.url(
                forResource: name, withExtension: "png"),
              let img = NSImage(contentsOf: url) else { return nil }
        cache[name] = img
        return img
    }

    private func outfitAsset(_ o: Outfit) -> String {
        switch o {
        case .crown:      return "crown"
        case .headphones: return "headphones"
        case .headband:   return "headband"
        case .wizardHat:  return "wizardhat"
        }
    }

    // True when every referenced asset loads from the bundle.
    public func assetsLoad() -> Bool {
        var names = ["base", "moneybag"]
        names += Outfit.allCases.map(outfitAsset)
        return names.allSatisfy { Self.asset($0) != nil }
    }

    public func image(outfit: Outfit, spending: Bool = false,
                      size: CGFloat = artSize) -> NSImage {
        let layers = ["base", outfitAsset(outfit)]
            + (spending ? ["moneybag"] : [])
        return NSImage(size: NSSize(width: size, height: size),
                       flipped: false) { rect in
            NSGraphicsContext.current?.imageInterpolation = .none
            for name in layers {
                Self.asset(name)?.draw(in: rect, from: .zero,
                    operation: .sourceOver, fraction: 1)
            }
            return true
        }
    }
}
