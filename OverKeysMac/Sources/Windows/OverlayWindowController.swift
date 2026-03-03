// OverlayWindowController.swift
// Custom NSWindow + NSWindowController that hosts the SwiftUI keyboard overlay.
// Properties: borderless, transparent, always-on-top, joins all spaces.

import AppKit
import SwiftUI
import Combine

// MARK: - Overlay NSWindow subclass

final class OverlayWindow: NSWindow {

    override var canBecomeKey: Bool  { false }
    override var canBecomeMain: Bool { false }

    /// Allow the window to be dragged by its background when click-through is OFF.
    override func mouseDown(with event: NSEvent) {
        if !ignoresMouseEvents {
            // Begin window drag
            performDrag(with: event)
        } else {
            super.mouseDown(with: event)
        }
    }
}

// MARK: - OverlayWindowController

final class OverlayWindowController: NSWindowController {

    private let viewModel: KeyboardViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init(viewModel: KeyboardViewModel) {
        self.viewModel = viewModel

        let window = OverlayWindow(
            contentRect: NSRect(
                x: viewModel.preferences.windowX,
                y: viewModel.preferences.windowY,
                width: 900,
                height: 200
            ),
            styleMask: [.borderless, .fullSizeContentView],
            backing:   .buffered,
            defer:     false
        )

        window.isOpaque             = false
        window.backgroundColor      = .clear
        window.hasShadow            = false
        window.level                = .floating           // NSWindowLevel(rawValue: 3)
        window.collectionBehavior   = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        window.ignoresMouseEvents   = viewModel.preferences.clickThrough
        window.isMovableByWindowBackground = !viewModel.preferences.clickThrough

        // Host SwiftUI content
        let rootView = KeyboardView(viewModel: viewModel)
        window.contentView = NSHostingView(rootView: rootView)

        super.init(window: window)
        bindViewModel()
    }

    required init?(coder: NSCoder) { fatalError("not used") }

    // MARK: - Bind viewModel → window properties

    private func bindViewModel() {
        guard let win = window else { return }

        // Opacity
        viewModel.$preferences
            .map(\.opacity)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak win] opacity in win?.alphaValue = CGFloat(opacity) }
            .store(in: &cancellables)

        // Click-through
        viewModel.$preferences
            .map(\.clickThrough)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak win] ct in
                win?.ignoresMouseEvents = ct
                win?.isMovableByWindowBackground = !ct
            }
            .store(in: &cancellables)

        // Always-on-top level
        viewModel.$preferences
            .map(\.alwaysOnTop)
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak win] onTop in
                win?.level = onTop ? .floating : .normal
            }
            .store(in: &cancellables)

        // Visibility
        viewModel.$isOverlayVisible
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in
                if visible {
                    self?.window?.orderFrontRegardless()
                } else {
                    self?.window?.orderOut(nil)
                }
            }
            .store(in: &cancellables)

        // Initial alpha
        win.alphaValue = CGFloat(viewModel.preferences.opacity)
    }

    // MARK: - Position persistence

    func savePosition() {
        guard let win = window else { return }
        let origin = win.frame.origin
        viewModel.updatePreferences {
            $0.windowX = Double(origin.x)
            $0.windowY = Double(origin.y)
        }
    }

    // MARK: - Show

    override func showWindow(_ sender: Any?) {
        window?.orderFrontRegardless()
    }

    // MARK: - Resize to fit content

    func fitToContent() {
        guard let win = window, let hosting = win.contentView as? NSHostingView<KeyboardView> else { return }
        let size = hosting.fittingSize
        var frame = win.frame
        frame.size = size
        win.setFrame(frame, display: true, animate: false)
    }
}

// MARK: - Multiple display support

extension OverlayWindowController {

    /// Move overlay to the screen at the given index (0-based).
    func moveToScreen(at index: Int) {
        let screens = NSScreen.screens
        guard index < screens.count, let win = window else { return }
        let screen = screens[index]
        let center = NSPoint(
            x: screen.visibleFrame.midX - win.frame.width  / 2,
            y: screen.visibleFrame.midY - win.frame.height / 2
        )
        win.setFrameOrigin(center)
        savePosition()
    }

    /// Move overlay to the screen that currently contains the mouse cursor.
    func moveToMouseScreen() {
        let mouseLocation = NSEvent.mouseLocation
        for (i, screen) in NSScreen.screens.enumerated() {
            if screen.frame.contains(mouseLocation) {
                moveToScreen(at: i)
                return
            }
        }
    }
}
