import AppKit
import SHAFTCore
final class StatusController: NSObject {
    private let item = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength)
    private let renderer = CritterRenderer()
    private let tmux = TmuxController(runner: ProcessCommandRunner())
    private let client = UsageClient(http: URLSessionHTTP(),
        tokens: SecurityCLITokenSource(runner: ProcessCommandRunner()))
    private var model: ClaudeModel = .opus
    private var mood: Mood = .fresh
    private var balance: String?
    private var timer: Timer?
    override init() {
        super.init()
        model = tmux.currentModel() ?? .opus
        render(); refresh()
    }
    private func render() {
        item.button?.image = renderer.image(mood: mood, outfit: model.outfit)
        item.menu = buildMenu()
    }
    private func buildMenu() -> NSMenu {
        let m = NSMenu()
        m.addItem(info("Model: \(model.displayName)"))
        m.addItem(info(balance ?? "Extra usage: off"))
        m.addItem(.separator())
        if tmux.hasSession() {
            m.addItem(modelSubmenu())
        } else {
            let s = NSMenuItem(title: "Start SHAFT session",
                action: #selector(startSession), keyEquivalent: "")
            s.target = self; m.addItem(s)
        }
        m.addItem(.separator())
        m.addItem(NSMenuItem(title: "Quit SHAFT",
            action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        return m
    }
    private func info(_ t: String) -> NSMenuItem {
        let i = NSMenuItem(title: t, action: nil, keyEquivalent: "")
        i.isEnabled = false; return i
    }
    private func modelSubmenu() -> NSMenuItem {
        let parent = NSMenuItem(title: "Switch model", action: nil,
            keyEquivalent: "")
        let sub = NSMenu()
        for cm in ClaudeModel.allCases {
            let mi = NSMenuItem(title: cm.displayName,
                action: #selector(pick(_:)), keyEquivalent: "")
            mi.target = self; mi.representedObject = cm
            mi.state = (cm == model) ? .on : .off
            sub.addItem(mi)
        }
        parent.submenu = sub; return parent
    }
    @objc private func startSession() { tmux.startSession(); render() }
    @objc private func pick(_ sender: NSMenuItem) {
        guard let cm = sender.representedObject as? ClaudeModel else { return }
        if tmux.switchModel(cm) { model = cm; render() }
        else { NSSound.beep() }                 // busy — retry when idle
    }
    private func refresh() {
        Task { @MainActor in
            guard let snap = try? await client.fetch() else {
                schedule(60); return
            }
            mood = Mood(usageFraction: snap.worstFraction)
            balance = BalanceLine.resolve(snap).display
            model = tmux.currentModel() ?? model
            render()
            schedule(pollInterval(worstFraction: snap.worstFraction))
        }
    }
    private func schedule(_ interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval,
            repeats: false) { [weak self] _ in self?.refresh() }
    }
}
