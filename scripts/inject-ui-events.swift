#!/usr/bin/env swift

import Foundation
import ApplicationServices
import AppKit

struct Config {
    var windowTitle: String = ""
    var windowId: Int?
    var events: String = ""
    var delayMs: Int = 35
    var dryRun: Bool = false
    var listWindows: Bool = false
}

struct WindowTarget {
    let windowId: Int
    let pid: pid_t
    let owner: String
    let title: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

let estimatedTitlebarHeight: Double = 28.0

func parseArgs() -> Config? {
    var cfg = Config()
    var i = 1
    let args = CommandLine.arguments
    while i < args.count {
        let a = args[i]
        if a == "--window", i + 1 < args.count {
            cfg.windowTitle = args[i + 1]
            i += 2
            continue
        }
        if a == "--window-id", i + 1 < args.count {
            cfg.windowId = Int(args[i + 1])
            i += 2
            continue
        }
        if a == "--events", i + 1 < args.count {
            cfg.events = args[i + 1]
            i += 2
            continue
        }
        if a == "--delay-ms", i + 1 < args.count {
            cfg.delayMs = Int(args[i + 1]) ?? 35
            i += 2
            continue
        }
        if a == "--dry-run" {
            cfg.dryRun = true
            i += 1
            continue
        }
        if a == "--list-windows" {
            cfg.listWindows = true
            i += 1
            continue
        }
        fputs("unknown arg: \(a)\n", stderr)
        return nil
    }
    if cfg.listWindows {
        return cfg
    }
    if (cfg.windowTitle.isEmpty && cfg.windowId == nil) || cfg.events.isEmpty {
        fputs("usage: inject-ui-events.swift (--window <title-substring> | --window-id <id>) --events \"<tokens>\" [--delay-ms N] [--dry-run] [--list-windows]\n", stderr)
        return nil
    }
    return cfg
}

func listWindows() -> [WindowTarget] {
    guard let raw = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
        return []
    }
    var out: [WindowTarget] = []
    for w in raw {
        guard let windowIdNum = w[kCGWindowNumber as String] as? NSNumber else { continue }
        guard let name = w[kCGWindowName as String] as? String else { continue }
        let owner = (w[kCGWindowOwnerName as String] as? String) ?? ""
        guard let pidNum = w[kCGWindowOwnerPID as String] as? NSNumber else { continue }
        guard let bounds = w[kCGWindowBounds as String] as? [String: Any] else { continue }
        let x = (bounds["X"] as? NSNumber)?.doubleValue ?? 0
        let y = (bounds["Y"] as? NSNumber)?.doubleValue ?? 0
        let width = (bounds["Width"] as? NSNumber)?.doubleValue ?? 0
        let height = (bounds["Height"] as? NSNumber)?.doubleValue ?? 0
        out.append(WindowTarget(windowId: windowIdNum.intValue, pid: pid_t(pidNum.intValue), owner: owner, title: name, x: x, y: y, width: width, height: height))
    }
    return out
}

func findWindow(titleContains needle: String) -> WindowTarget? {
    let n = needle.lowercased()
    for w in listWindows() {
        if w.title.lowercased().contains(n) || w.owner.lowercased().contains(n) {
            return w
        }
    }
    return nil
}

func findWindow(id windowId: Int) -> WindowTarget? {
    for w in listWindows() {
        if w.windowId == windowId { return w }
    }
    return nil
}

func activateWindowOwner(_ pid: pid_t) {
    if let app = NSRunningApplication(processIdentifier: pid) {
        _ = app.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        usleep(260_000)
    }
}

func postMouseClick(x: Double, y: Double) {
    let p = CGPoint(x: x, y: y)
    let src = CGEventSource(stateID: .combinedSessionState)
    let move = CGEvent(mouseEventSource: src, mouseType: .mouseMoved, mouseCursorPosition: p, mouseButton: .left)
    let down = CGEvent(mouseEventSource: src, mouseType: .leftMouseDown, mouseCursorPosition: p, mouseButton: .left)
    let up = CGEvent(mouseEventSource: src, mouseType: .leftMouseUp, mouseCursorPosition: p, mouseButton: .left)
    move?.post(tap: .cghidEventTap)
    usleep(18_000)
    down?.post(tap: .cghidEventTap)
    usleep(18_000)
    up?.post(tap: .cghidEventTap)
}

func contentPoint(for target: WindowTarget, rx: Double, ry: Double) -> (Double, Double) {
    return (target.x + rx, target.y + estimatedTitlebarHeight + ry)
}

func keyCodeMap() -> [String: CGKeyCode] {
    return [
        "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7, "c": 8, "v": 9, "b": 11,
        "q": 12, "w": 13, "e": 14, "r": 15, "y": 16, "t": 17,
        "1": 18, "2": 19, "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
        "]": 30, "o": 31, "u": 32, "[": 33, "i": 34, "p": 35,
        "l": 37, "j": 38, "'": 39, "k": 40, ";": 41, "\\": 42, ",": 43, "/": 44, "n": 45, "m": 46, ".": 47, "`": 50,
        "enter": 36, "return": 36, "tab": 48, "space": 49, "backspace": 51, "escape": 53, "esc": 53,
        "left": 123, "right": 124, "down": 125, "up": 126, "delete": 117
    ]
}

func modifierFlags(_ parts: [String]) -> CGEventFlags {
    var f: CGEventFlags = []
    for p in parts {
        let s = p.lowercased()
        if s == "cmd" || s == "command" { f.insert(.maskCommand) }
        if s == "ctrl" || s == "control" { f.insert(.maskControl) }
        if s == "opt" || s == "alt" { f.insert(.maskAlternate) }
        if s == "shift" { f.insert(.maskShift) }
    }
    return f
}

func postKey(name raw: String) {
    let parts = raw.split(separator: "+").map(String.init)
    let base = parts.last?.lowercased() ?? raw.lowercased()
    guard let code = keyCodeMap()[base] else { return }
    let flags = modifierFlags(Array(parts.dropLast()))
    let src = CGEventSource(stateID: .combinedSessionState)
    let down = CGEvent(keyboardEventSource: src, virtualKey: code, keyDown: true)
    let up = CGEvent(keyboardEventSource: src, virtualKey: code, keyDown: false)
    down?.flags = flags
    up?.flags = flags
    down?.post(tap: .cghidEventTap)
    usleep(9_000)
    up?.post(tap: .cghidEventTap)
}

func postText(_ text: String) {
    let src = CGEventSource(stateID: .combinedSessionState)
    for scalar in text.unicodeScalars {
        var c = Array(String(scalar).utf16)
        let down = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: true)
        let up = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: false)
        down?.keyboardSetUnicodeString(stringLength: c.count, unicodeString: &c)
        up?.keyboardSetUnicodeString(stringLength: c.count, unicodeString: &c)
        down?.post(tap: .cghidEventTap)
        usleep(8_000)
        up?.post(tap: .cghidEventTap)
    }
}

func parseCoords(_ s: String) -> (Double, Double)? {
    let p = s.split(separator: ",").map(String.init)
    if p.count != 2 { return nil }
    guard let x = Double(p[0]), let y = Double(p[1]) else { return nil }
    return (x, y)
}

func ensureAccessibilityNotice() {
    if !AXIsProcessTrusted() {
        fputs("[warn] Accessibility permission is required for event injection.\n", stderr)
    }
}

guard let cfg = parseArgs() else { exit(2) }
if cfg.listWindows {
    for w in listWindows() {
        print("\(w.windowId)\t\(w.owner)\t\(w.title)\t\(Int(w.width))x\(Int(w.height))+\(Int(w.x))+\(Int(w.y))")
    }
    exit(0)
}
let target: WindowTarget?
if cfg.dryRun {
    target = nil
} else {
    let resolved: WindowTarget?
    if let windowId = cfg.windowId {
        resolved = findWindow(id: windowId)
    } else {
        resolved = findWindow(titleContains: cfg.windowTitle)
    }
    guard let resolved else {
        if let windowId = cfg.windowId {
            fputs("window not found with id: \(windowId)\n", stderr)
        } else {
            fputs("window not found containing title: \(cfg.windowTitle)\n", stderr)
        }
        exit(3)
    }
    target = resolved
    activateWindowOwner(resolved.pid)
    ensureAccessibilityNotice()
}

let tokens = cfg.events.split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }

for token in tokens {
    if cfg.dryRun {
        print("[dry-run] \(token)")
        continue
    }
    if token == "close" {
        postKey(name: "cmd+w")
    } else if token.hasPrefix("wait:") {
        let s = String(token.dropFirst(5))
        let ms = Int(s) ?? cfg.delayMs
        usleep(useconds_t(max(0, ms) * 1000))
        continue
    } else if token.hasPrefix("text:") {
        let s = String(token.dropFirst(5))
        postText(s)
    } else if token.hasPrefix("key:") {
        let s = String(token.dropFirst(4))
        postKey(name: s)
    } else if token.hasPrefix("clickr:") || token.hasPrefix("touchr:") {
        let s = String(token.dropFirst(7))
        if let (rx, ry) = parseCoords(s), let t = target {
            let (x, y) = contentPoint(for: t, rx: rx, ry: ry)
            postMouseClick(x: x, y: y)
        }
    } else if token.hasPrefix("click:") || token.hasPrefix("touch:") {
        let s = String(token.dropFirst(6))
        if let (x, y) = parseCoords(s) {
            postMouseClick(x: x, y: y)
        }
    }
    usleep(useconds_t(max(0, cfg.delayMs) * 1000))
}

print("injected \(tokens.count) event token(s)")
