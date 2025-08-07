import Cocoa
import ReSwift

enum AppDelegateAction: Action {
    case didFinishLaunching
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_: Notification) {
        let statusBar = NSStatusBar.system

        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

        statusBarItem.button?.title = "🖥"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Toggle window", action: #selector(toggleWindow(_:)), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem.menu = menu

        let viewController = ScreenViewController()
        window = NSWindow(contentViewController: viewController)
        window.delegate = viewController
        window.title = "DeskPad"
        window.makeKeyAndOrderFront(nil)
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.titleVisibility = .hidden
        window.backgroundColor = .white
        window.contentMinSize = CGSize(width: 400, height: 300)
        window.contentMaxSize = CGSize(width: 5120, height: 2160)
        window.styleMask.insert(.resizable)
        window.collectionBehavior.insert(.fullScreenNone)
        window.orderOut(nil)

        let mainMenu = NSMenu()
        let mainMenuItem = NSMenuItem()
        let subMenu = NSMenu(title: "MainMenu")
        let quitMenuItem = NSMenuItem(
            title: "Quit",
            action: #selector(NSApp.terminate),
            keyEquivalent: "q"
        )
        subMenu.addItem(quitMenuItem)
        mainMenuItem.submenu = subMenu
        mainMenu.items = [mainMenuItem]
        NSApplication.shared.mainMenu = mainMenu

        store.dispatch(AppDelegateAction.didFinishLaunching)
    }

    @objc func toggleWindow(_: Any?) {
        guard let window = window else { return }

        if window.isVisible {
            window.orderOut(nil)
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return false
    }
}
