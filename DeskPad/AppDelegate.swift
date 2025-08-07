import Cocoa
import ReSwift

enum AppDelegateAction: Action {
    case didFinishLaunching
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var pinButtonItem: NSToolbarItem!
    var isPinned: Bool = false

    func applicationDidFinishLaunching(_: Notification) {
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

        // Add toolbar with pin button
        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.delegate = self
        window.toolbar = toolbar

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

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return true
    }

    @objc func togglePin(_: Any?) {
        isPinned.toggle()
        window.level = isPinned ? .floating : .normal
        updatePinButtonImage()
        if let button = pinButtonItem?.view as? NSButton {
            button.state = isPinned ? .on : .off
        }
    }

    private func updatePinButtonImage() {
        guard let button = pinButtonItem?.view as? NSButton else { return }
        let buttonSize: CGFloat = 18
        button.frame = NSRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        let config = NSImage.SymbolConfiguration(pointSize: buttonSize - 4, weight: .regular)
        if let pinImage = NSImage(systemSymbolName: "pin", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
            if isPinned {
                let rotated = pinImage.copy() as! NSImage
                rotated.lockFocus()
                let transform = NSAffineTransform()
                transform.translateX(by: rotated.size.width / 2, yBy: rotated.size.height / 2)
                transform.rotate(byDegrees: 270)
                transform.translateX(by: -rotated.size.width / 2, yBy: -rotated.size.height / 2)
                transform.concat()
                pinImage.draw(at: .zero, from: NSRect(origin: .zero, size: rotated.size), operation: .copy, fraction: 1.0)
                rotated.unlockFocus()
                button.image = rotated
            } else {
                button.image = pinImage
            }
            button.title = ""
            button.imagePosition = .imageOnly
        }
    }
}

extension AppDelegate: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .init("PinButton")]
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .init("PinButton")]
    }

    func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
        if itemIdentifier.rawValue == "PinButton" {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let button = NSButton()
            button.target = self
            button.action = #selector(togglePin(_:))
            button.setButtonType(.toggle)
            button.bezelStyle = .texturedRounded
            item.view = button
            pinButtonItem = item
            updatePinButtonImage()
            return item
        }
        return nil
    }
}
