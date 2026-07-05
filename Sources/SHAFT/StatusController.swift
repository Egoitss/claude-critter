import AppKit
import SHAFTCore
final class StatusController: NSObject {
    private let item = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength)
    private let renderer = CritterRenderer()
    private let pet = PetWindow()
    private let tmux = TmuxController(runner: ProcessCommandRunner())
    private let client = UsageClient(http: URLSessionHTTP(),
        tokens: SecurityCLITokenSource(runner: ProcessCommandRunner()))
    private var model: ClaudeModel = .opus
    private var usage: Double = 0
    private var balance: String?
    private var timer: Timer?
    private var target = "claude"
    override init() {
        super.init()
        model = SettingsModel.current() ?? .opus
        let s = tmux.controllableSessions()
        target = s.contains("claude") ? "claude" : (s.first ?? "claude")
        tmux.session = target
        render(); refresh()
    }
    private func render() {
        let spending = balance != nil          // extra-usage / API in play
        item.button?.image = renderer.image(
            usage: usage, outfit: model.outfit, spending: spending)
        item.menu = buildMenu()
        pet.update(
            image: renderer.image(usage: usage, outfit: model.outfit,
                                  spending: spending, size: 96),
            menu: buildMenu())
    }
    private func buildMenu() -> NSMenu {
        let m = NSMenu()
        m.addItem(info("Model: \(model.displayName)"))
        m.addItem(info(balance ?? "Extra usage: off"))
        m.addItem(.separator())
        let sessions = tmux.controllableSessions()
        if sessions.isEmpty {
            let s = NSMenuItem(title: "Start SHAFT session",
                action: #selector(startSession), keyEquivalent: "")
            s.target = self; m.addItem(s)
        } else {
            m.addItem(targetSubmenu(sessions))
            m.addItem(modelSubmenu())
        }
        m.addItem(.separator())
        let petTitle = pet.isVisible ? "Hide pet" : "Show pet"
        let petItem = NSMenuItem(title: petTitle,
            action: #selector(togglePet), keyEquivalent: "")
        petItem.target = self; m.addItem(petItem)
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
    private func targetSubmenu(_ sessions: [String]) -> NSMenuItem {
        let parent = NSMenuItem(title: "Target", action: nil,
            keyEquivalent: "")
        let sub = NSMenu()
        for name in sessions {
            let mi = NSMenuItem(title: name,
                action: #selector(pickTarget(_:)), keyEquivalent: "")
            mi.target = self; mi.representedObject = name
            mi.state = (name == target) ? .on : .off
            sub.addItem(mi)
        }
        parent.submenu = sub; return parent
    }
    @objc private func startSession() { tmux.startSession(); render() }
    @objc private func togglePet() {
        pet.setVisible(!pet.isVisible); render()
    }
    @objc private func pickTarget(_ sender: NSMenuItem) {
        guard let name = sender.representedObject as? String else { return }
        target = name; tmux.session = name; render()
    }
    @objc private func pick(_ sender: NSMenuItem) {
        guard let cm = sender.representedObject as? ClaudeModel else { return }
        if tmux.session != target { tmux.session = target }
        if tmux.switchModel(cm) { model = cm; render() }
        else { NSSound.beep() }                 // busy — retry when idle
    }
    private func refresh() {
        Task { @MainActor in
            model = SettingsModel.current() ?? model   // reliable, no tmux
            guard let snap = try? await client.fetch() else {
                render(); schedule(60); return
            }
            usage = snap.worstFraction
            balance = BalanceLine.resolve(snap).display
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
