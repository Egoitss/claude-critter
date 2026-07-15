import AppKit

/// An `NSImageView` that initiates a real window drag on mouse-down,
/// since `isMovableByWindowBackground` is unreliable for a
/// `.nonactivatingPanel`. Right-click runs `onRightClick` when set
/// (the gauge strip cycles metrics); otherwise it opens `.menu`
/// normally via the superclass.
final class PetView: NSImageView {
    var onRightClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let handler = onRightClick else {
            super.rightMouseDown(with: event)
            return
        }
        handler()
    }
}

/// A small always-on-top floating panel that shows the critter as a
/// draggable desktop pet, mirroring the menu-bar icon and its controls.
final class PetWindow {
    private static let side: CGFloat = 128   // matches the 128px source art
    private static let gaugeH: CGFloat = 28
    private let panel: NSPanel
    private let imageView = PetView()
    private let gaugeView = PetView()

    init() {
        let side = Self.side
        let h = side + Self.gaugeH
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: side, height: h),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false)
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [
            .canJoinAllSpaces, .fullScreenAuxiliary,
        ]
        let content = NSView(
            frame: NSRect(x: 0, y: 0, width: side, height: h))
        imageView.frame = NSRect(
            x: 0, y: Self.gaugeH, width: side, height: side)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        gaugeView.frame = NSRect(
            x: 0, y: 0, width: side, height: Self.gaugeH)
        gaugeView.imageScaling = .scaleProportionallyUpOrDown
        content.addSubview(imageView)
        content.addSubview(gaugeView)
        panel.contentView = content
        positionBottomRight(side: side)
        panel.orderFrontRegardless()
    }

    private func positionBottomRight(side: CGFloat) {
        guard let visible =
            (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame
        else { return }
        let x = visible.maxX - side - 24
        let y = visible.minY + 24
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    func update(image: NSImage, gauge: NSImage, menu: NSMenu) {
        imageView.image = image
        imageView.menu = menu
        gaugeView.image = gauge
        // Fallback only: unreachable while onGaugeRightClick is set,
        // which redirects the gauge's right-click to metric cycling.
        gaugeView.menu = menu
    }

    func setVisible(_ v: Bool) {
        if v { panel.orderFrontRegardless() } else { panel.orderOut(nil) }
    }

    var isVisible: Bool { panel.isVisible }

    /// Fired when the gauge strip is right-clicked; the critter view
    /// keeps the default context-menu behavior.
    var onGaugeRightClick: (() -> Void)? {
        get { gaugeView.onRightClick }
        set { gaugeView.onRightClick = newValue }
    }
}
