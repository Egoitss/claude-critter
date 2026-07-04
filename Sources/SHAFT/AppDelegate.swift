import AppKit
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: StatusController?
    func applicationDidFinishLaunching(_ n: Notification) {
        controller = StatusController()
    }
}
