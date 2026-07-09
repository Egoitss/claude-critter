import Foundation

// Color keys for sprite cells; Critter maps them to NSColor. Keeping keys
// AppKit-free lets the grids stay pure data.
public enum SpriteInk {
    case body, eye, yellow, red, blue, white, green, hatBlue, brown
}

// One overlay: a 20-row grid plus the ink each symbol paints.
public struct OutfitSprite {
    public let rows: [String]
    public let ink: [Character: SpriteInk]
    public init(rows: [String], ink: [Character: SpriteInk]) {
        self.rows = rows
        self.ink = ink
    }
}
