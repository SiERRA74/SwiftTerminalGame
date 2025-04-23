#if os(Linux)
import Glibc
#else
import Darwin
#endif

// Terminal mode control
public func enableRawMode() -> termios {
    var originalSettings = termios()
    tcgetattr(STDIN_FILENO, &originalSettings)

    var newSettings = originalSettings
    newSettings.c_lflag &= ~UInt32(ICANON | ECHO)  // Changed to UInt32
    tcsetattr(STDIN_FILENO, TCSANOW, &newSettings)

    return originalSettings
}

public func disableRawMode(originalSettings: termios) {
    var settings = originalSettings  // Create mutable copy
    tcsetattr(STDIN_FILENO, TCSANOW, &settings)  // Pass mutable copy
}

// Key detection (only left/right/enter)
public func readKeyPress() -> String? {
    let originalSettings = enableRawMode()
    defer { disableRawMode(originalSettings: originalSettings) }

    var char: UInt8 = 0
    guard read(STDIN_FILENO, &char, 1) == 1 else { return nil }

    if char == 27 { // ESC sequence
        guard read(STDIN_FILENO, &char, 1) == 1 else { return nil }
        if char == 91 { // '['
            guard read(STDIN_FILENO, &char, 1) == 1 else { return nil }
            return char == 68 ? "left" : char == 67 ? "right" : nil
        }
    }
    else if char == 10 { return "enter" }

    return nil
}
