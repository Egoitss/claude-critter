import Foundation

// Hand-authored pixel-grid critter (12x12), transcribed from the reference
// sprite. Rows are top->bottom. Legend: '.' empty, 'B' body (mood-tinted),
// 'K' eye (black), 'A' accent (outfit-colored, drawn on top of the base).
// Tweak individual cells here to reshape the critter — no assets needed.

enum CritterSprite {
    static let dim = 12

    static let base: [String] = [
        "............",
        "............",
        "..BBBBBBBB..",
        "..BBBBBBBB..",
        "..BKKBBKKB..",
        "..BKKBBKKB..",
        "..BBBBBBBB..",
        "..BBBBBBBB..",
        "..BBBBBBBB..",
        "..BBBBBBBB..",
        "..BB.BB.BB..",
        "..BB.BB.BB..",
    ]

    // Each overlay is 12 rows; 'A' cells paint in the outfit accent color.
    static let outfits: [Outfit: [String]] = [
        .crown: [
            "..A.A.A.A...",
            "..AAAAAAAA..",
            "............", "............", "............",
            "............", "............", "............",
            "............", "............", "............",
            "............",
        ],
        .headphones: [
            "............",
            "...AAAAAA...",
            "............", "............",
            ".A........A.",
            ".A........A.",
            "............", "............", "............",
            "............", "............", "............",
        ],
        .headband: [
            "............", "............", "............",
            "..AAAAAAAA..",
            "..........A.",
            "............", "............", "............",
            "............", "............", "............",
            "............",
        ],
        .wizardHat: [
            ".....AA.....",
            "....AAAA....",
            "..AAAAAAAA..",
            "............", "............", "............",
            "............", "............", "............",
            "............", "............", "............",
        ],
    ]
}
