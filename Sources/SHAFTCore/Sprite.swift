import Foundation

// Hand-authored 20x20 square critter. Rows top->bottom. Legend: '.' empty,
// 'B' body, 'K' eye. Overlays (OutfitSprite) carry their own inks.
private let e = "...................."   // one empty 20-wide row

enum CritterSprite {
    static let dim = 20

    static let base: [String] = [
        e, e, e,
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBKKBBBBBBBBKKBB..",
        "..BBKKBBBBBBBBKKBB..",
        "BBBBBBBBBBBBBBBBBBBB",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
    ]

    static let outfits: [Outfit: OutfitSprite] = [
        .crown: OutfitSprite(
            rows: [".....G...G...G......",
                   "....AAA.AAA.AAA.....",
                   "....AAAAAAAAAAAA...."]
                + Array(repeating: e, count: 17),
            ink: ["A": .yellow, "G": .red]),
        .headphones: OutfitSprite(rows: [
            e,
            "..HHHHHHHHHHHHHHHH..",
            ".HH..............HH.",
            ".H................H.",
            ".H................H.",
            ".H................H.",
            "HHH..............HHH",
            "HHH..............HHH",
            "HHH..............HHH",
            ".HH..............HH.",
            e,
            ".................H..",
            "...............HP...",
            "..............PPP...",
            "..............PPP...",
            e, e, e, e, e,
        ], ink: ["H": .blue, "P": .white]),
        .headband: OutfitSprite(rows: [
            e, e, e,
            "..NNNNNNNNNNNNNNNN..",
            ".................NN.",
            "..................NN",
            e, e, e, e, e, e, e, e, e, e, e, e, e, e,
        ], ink: ["N": .green]),
    ]

    static let moneyBag = OutfitSprite(
        rows: Array(repeating: e, count: 10)
            + ["................MM..",
               "...............MMMM.",
               "...............MDDM.",
               "...............MDDM.",
               "...............MMMM."]
            + Array(repeating: e, count: 5),
        ink: ["M": .brown, "D": .yellow])
}
