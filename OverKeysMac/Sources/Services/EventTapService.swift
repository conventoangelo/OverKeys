// EventTapService.swift
// Global key capture via CGEventTap (Quartz Event Services).
// Runs on a dedicated thread; publishes events via callbacks on the main queue.

import CoreGraphics
import AppKit
import Foundation

// MARK: - EventTapService

final class EventTapService: @unchecked Sendable {

    // MARK: Callbacks (dispatched on main queue)
    var onKeyDown:          ((CGKeyCode, CGEventFlags) -> Void)?
    var onKeyUp:            ((CGKeyCode, CGEventFlags) -> Void)?
    var onFlagsChanged:     ((CGKeyCode, CGEventFlags) -> Void)?
    var onPermissionDenied: (() -> Void)?

    // MARK: Private state
    private var eventTap:      CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var tapRunLoop:    CFRunLoop?
    private var tapThread:     Thread?
    private var isRunning      = false

    // MARK: - Start

    func start() {
        guard !isRunning else { return }
        fputs("[EventTap] start() called\n", stderr)

        let eventMask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue)              |
            (1 << CGEventType.keyUp.rawValue)                |
            (1 << CGEventType.flagsChanged.rawValue)         |
            (1 << CGEventType.tapDisabledByTimeout.rawValue) |
            (1 << CGEventType.tapDisabledByUserInput.rawValue)

        // Pass unretained self via userInfo — self must outlive the tap.
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        // Non-capturing closure → bridged to C function pointer by Swift.
        // Self is recovered from the userInfo raw pointer inside.
        let callback: CGEventTapCallBack = { _, type, event, userInfo -> Unmanaged<CGEvent>? in
            guard let userInfo else { return Unmanaged.passRetained(event) }
            let svc = Unmanaged<EventTapService>.fromOpaque(userInfo).takeUnretainedValue()
            svc.dispatch(type: type, event: event)
            return Unmanaged.passRetained(event)
        }

        // Xcode 26 / macOS 26 SDK: CGEventTapCreate → CGEvent.tapCreate(tap:place:options:...)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: userInfo
        ) else {
            fputs("[EventTap] CGEvent.tapCreate FAILED — Accessibility permission not granted?\n", stderr)
            DispatchQueue.main.async { [weak self] in self?.onPermissionDenied?() }
            return
        }
        fputs("[EventTap] CGEvent.tapCreate succeeded\n", stderr)

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source

        // Run tap on a private thread so we never block the main run loop.
        let thread = Thread { [weak self] in
            guard let self else { return }
            self.tapRunLoop = CFRunLoopGetCurrent()
            CFRunLoopAddSource(self.tapRunLoop, source, CFRunLoopMode.commonModes)
            // Xcode 26 SDK: CGEventTapEnable → CGEvent.tapEnable(tap:enable:)
            CGEvent.tapEnable(tap: tap, enable: true)
            CFRunLoopRun()
        }
        thread.name = "OverKeys.EventTap"
        thread.start()
        tapThread = thread
        isRunning = true
    }

    // MARK: - Stop

    func stop() {
        guard isRunning else { return }
        isRunning = false

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource, let rl = tapRunLoop {
            CFRunLoopRemoveSource(rl, source, CFRunLoopMode.commonModes)
            CFRunLoopStop(rl)
        }
        eventTap      = nil
        runLoopSource = nil
        tapRunLoop    = nil
        tapThread     = nil
    }

    // MARK: - Event dispatch (tap thread → main queue)

    private func dispatch(type: CGEventType, event: CGEvent) {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags   = event.flags

        // Verbose: describe modifier flags for any event that carries them
        let modDesc: String = {
            var parts: [String] = []
            if flags.contains(.maskCommand)   { parts.append("Cmd") }
            if flags.contains(.maskAlternate)  { parts.append("Alt") }
            if flags.contains(.maskControl)    { parts.append("Ctrl") }
            if flags.contains(.maskShift)      { parts.append("Shift") }
            if flags.contains(.maskSecondaryFn){ parts.append("Fn") }
            if flags.contains(.maskAlphaShift) { parts.append("Caps") }
            return parts.isEmpty ? "" : " flags=[\(parts.joined(separator: "+"))]"
        }()

        switch type {
        case .keyDown:
            let label = KeyMapping.label(for: keyCode)
            fputs("[EventTap] keyDown \(keyCode) \"\(label)\"\(modDesc)\n", stderr)
            DispatchQueue.main.async { [weak self] in self?.onKeyDown?(keyCode, flags) }
        case .keyUp:
            let label = KeyMapping.label(for: keyCode)
            fputs("[EventTap] keyUp \(keyCode) \"\(label)\"\(modDesc)\n", stderr)
            DispatchQueue.main.async { [weak self] in self?.onKeyUp?(keyCode, flags) }
        case .flagsChanged:
            let modLabel = KeyMapping.modifierLabel(for: keyCode) ?? "?\(keyCode)"
            fputs("[EventTap] flagsChanged \(modLabel)\(modDesc)\n", stderr)
            DispatchQueue.main.async { [weak self] in self?.onFlagsChanged?(keyCode, flags) }
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            reenableTap()
        default:
            fputs("[EventTap] event type=\(type.rawValue) code=\(keyCode)\(modDesc)\n", stderr)
            break
        }
    }

    // MARK: - Re-enable after OS-initiated disable

    private func reenableTap() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }
}
