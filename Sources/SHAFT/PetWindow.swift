import AppKit

/// A small always-on-top floating panel that shows the critter as a
/// draggable desktop pet, mirroring the menu-bar icon and its controls.
final class PetWindow {
    private static let side: CGFloat = 96
    private let panel: NSPanel
    private let imageView = NSImageView()

    init() {
        let side = Self.side
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: side, height: side),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false)
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [
            .canJoinAllSpaces, .fullScreenAuxiliary,
        ]

        imageView.frame = NSRect(x: 0, y: 0, width: side, height: side)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        panel.contentView = imageView

        if let visible = NSScreen.main?.visibleFrame {
            let x = visible.maxX - side - 24
            let y = visible.minY + 24
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        panel.orderFrontRegardless()
    }

    func update(image: NSImage, menu: NSMenu) {
        imageView.image = image
        imageView.menu = menu
    }

    func setVisible(_ v: Bool) {
        if v { panel.orderFrontRegardless() } else { panel.orderOut(nil) }
    }

    var isVisible: Bool { panel.isVisible }
}
