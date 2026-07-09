import Foundation

// 3x5 bitmap font + heart for the usage gauge. '#' = an ink pixel.
public enum PixelFont {
    public static let heart: [String] = [
        ".#.#.", "#####", "#####", ".###.", "..#..",
    ]
    static let glyphs: [Character: [String]] = [
        "0": ["###", "#.#", "#.#", "#.#", "###"],
        "1": [".#.", "##.", ".#.", ".#.", "###"],
        "2": ["###", "..#", "###", "#..", "###"],
        "3": ["###", "..#", "###", "..#", "###"],
        "4": ["#.#", "#.#", "###", "..#", "..#"],
        "5": ["###", "#..", "###", "..#", "###"],
        "6": ["###", "#..", "###", "#.#", "###"],
        "7": ["###", "..#", "..#", "..#", "..#"],
        "8": ["###", "#.#", "###", "#.#", "###"],
        "9": ["###", "#.#", "###", "..#", "###"],
        "%": ["#.#", "..#", ".#.", "#..", "#.#"],
    ]
    public static func glyph(_ ch: Character) -> [String] {
        glyphs[ch] ?? ["...", "...", "...", "...", "..."]
    }
    // Glyphs joined left-to-right with a 1-column gap; 5 rows out.
    public static func text(_ s: String) -> [String] {
        var rows = Array(repeating: "", count: 5)
        for (i, ch) in s.enumerated() {
            let g = glyph(ch)
            for r in 0..<5 { rows[r] += (i == 0 ? "" : ".") + g[r] }
        }
        return rows
    }
}
