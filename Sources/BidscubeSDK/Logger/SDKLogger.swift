import Foundation
import os

class SDKLogger {
    nonisolated(unsafe) private static var isLoggingEnabled = true

    static func setLoggingEnabled(_ enabled: Bool) {
        isLoggingEnabled = enabled
    }

    static func d(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        log(.debug, tag, message)
        print("🔍 [DEBUG] [\(tag)] \(message)")
    }

    static func i(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        log(.info, tag, message)
        print("Info: [INFO] [\(tag)] \(message)")
    }

    static func w(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        log(.warning, tag, message)
        print("⚠️ [WARNING] [\(tag)] \(message)")
    }

    static func e(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        log(.error, tag, message)
        print("Error: [ERROR] [\(tag)] \(message)")
    }

    static func v(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        log(.debug, tag, message)
        print("📝 [VERBOSE] [\(tag)] \(message)")
    }

    private enum Level { case debug, info, warning, error }

    private static func log(_ level: Level, _ tag: String, _ message: String) {
        guard #available(iOS 14.0, tvOS 14.0, *) else { return }
        let line = "[\(tag)] \(message)"
        switch level {
        case .debug: AppleLog.logger.debug("\(line)")
        case .info: AppleLog.logger.info("\(line)")
        case .warning: AppleLog.logger.warning("\(line)")
        case .error: AppleLog.logger.error("\(line)")
        }
    }
}

@available(iOS 14.0, tvOS 14.0, *)
private enum AppleLog {
    static let logger = os.Logger(subsystem: "com.bidscube.sdk", category: "SDK")
}
