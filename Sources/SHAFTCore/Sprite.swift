import Foundation

// Hand-authored pixel-grid critter (18x18). Rows top->bottom. Legend:
// '.' empty, 'B' body (usage-colored), 'K' eye (black), 'A' accent (outfit
// color, on top). Beefy side ears bulge out at rows 6-8; eyes are wide-set;
// 4 legs with the outer pair flush to the body edge. Each grid is 18 rows.

enum CritterSprite {
    static let dim = 18

    // Rows (top, bottom) that contain the critter's body — drives the usage
    // gauge (grey fills from the bottom row up).
    static var bodyRowRange: (Int, Int) {
        let rows = base.indices.filter {
            base[$0].contains("B") || base[$0].contains("K")
        }
        return (rows.first ?? 0, rows.last ?? dim - 1)
    }

    static let base: [String] = [
        "..................",
        "..................",
        "..................",
        "..BBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBB..",
        "BBBBKKBBBBBBKKBBBB",   // beefy ears + wide-set eyes
        "BBBBKKBBBBBBKKBBBB",
        "BBBBBBBBBBBBBBBBBB",   // ears (no eyes)
        "..BBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBB..",
        "..BB..BB..BB..BB..",   // 4 legs, outer pair flush to edge
        "..BB..BB..BB..BB..",
        "..BB..BB..BB..BB..",
        "..................",
    ]

    static let outfits: [Outfit: [String]] = [
        .crown: [
            "..................",
            "...A.A.A.A.A.A....",
            "...AAAAAAAAAAAA...",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
        ],
        .headphones: [
            "..................", "..................",
            "...AAAAAAAAAAAA...",
            "..................", "..................", "..................",
            "AA..............AA",
            "AA..............AA",
            "AA..............AA",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
        ],
        .headband: [
            "..................", "..................", "..................",
            "..................", "..................",
            "..AAAAAAAAAAAAAA..",
            "................AA",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................",
        ],
        .wizardHat: [
            "........AA........",
            ".......AAAA.......",
            "..AAAAAAAAAAAAAA..",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
            "..................", "..................", "..................",
        ],
    ]

    // Drawn on top of everything when the critter is spending money
    // (extra-usage / API credits) — a small gold bag held at the lower
    // right. 'M' = bag body, 'D' = the $ mark.
    static let moneyBag: [String] = [
        "..................", "..................", "..................",
        "..................", "..................", "..................",
        "..................", "..................", "..................",
        "...............MM.",
        "..............MMMM",
        "..............MDDM",
        "..............MDDM",
        "..............MMMM",
        "..................", "..................", "..................",
        "..................",
    ]
}
