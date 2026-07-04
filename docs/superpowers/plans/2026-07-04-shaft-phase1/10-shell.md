### Task 10: AppKit shell + manual verification

**Files:**
- Modify: `Sources/SHAFT/main.swift`
- Create: `Sources/SHAFT/AppDelegate.swift`
- Create: `Sources/SHAFT/StatusController.swift`

**Interfaces:**
- Consumes: the full `SHAFTCore` surface (Tasks 2–9) — renderer, tmux
  controller, usage client, model/mood/balance types, I/O structs.
- Produces: a running menu-bar agent. No unit tests — verified manually.

- [ ] **Step 1: Replace `main.swift`**

```swift
import AppKit
let app = NSApplication.shared
app.setActivationPolicy(.accessory)      // menu-bar only, no Dock icon
let delegate = AppDelegate()
app.delegate = delegate
app.run()
```

- [ ] **Step 2: Add `AppDelegate.swift`**

```swift
import AppKit
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: StatusController?
    func applicationDidFinishLaunching(_ n: Notification) {
        controller = StatusController()
    }
}
```

- [ ] **Step 3: Add `StatusController.swift`**

```swift
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
```

- [ ] **Step 4: Build + manual verification**

```bash
swift build
swift run SHAFT        # menu-bar critter appears; Ctrl-C or Quit to stop
```

Verify, in order:
1. A colored critter icon appears in the menu bar.
2. With no tmux session, the menu shows **Start SHAFT session**; clicking it
   creates one (`tmux has-session -t claude` now succeeds).
3. In that session run `claude`; the menu now shows **Switch model** → pick
   Sonnet; the session receives `/model sonnet` and switches. The submenu
   check-mark and the critter's outfit accent follow the choice.
4. While Claude is streaming a reply, picking a model beeps (idle gate) — it
   lands once the reply finishes. **If it does not gate, confirm the busy
   marker string in `Tmux.swift` against the live TUI and update it.**
5. Usage lines/mood reflect your real plan usage. **If a `/model` alias is
   rejected, correct `ClaudeModel.modelArg` (Task 2).**
6. Balance line shows `€… left of €…` only when extra usage is enabled;
   otherwise it reads "Extra usage: off". **Confirm the currency and that
   `monthly_limit` is in major units, not cents; adjust `Balance.swift` if
   needed.**

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFT
git commit -m "feat: menu-bar shell wiring meter + tmux switcher"
```
