import Foundation
import os

enum Log {
    private static let subsystem = "com.brivo.claude.postshub"

    static let app      = Logger(subsystem: subsystem, category: "App")
    static let api      = Logger(subsystem: subsystem, category: "API")
    static let store    = Logger(subsystem: subsystem, category: "Store")
    static let list     = Logger(subsystem: subsystem, category: "List")
    static let detail   = Logger(subsystem: subsystem, category: "Detail")
    static let row      = Logger(subsystem: subsystem, category: "Row")
    static let favorites = Logger(subsystem: subsystem, category: "Favorites")
    static let filter   = Logger(subsystem: subsystem, category: "Filter")
}

extension Logger {
    func event(_ message: String) {
        let ts = Log.timestamp()
        self.debug("\(ts, privacy: .public) \(message, privacy: .public)")
    }
}

extension Log {
    static func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: Date())
    }

    static func dumpDecodingError(_ error: Error, data: Data, logger: Logger) {
        let preview: String = {
            guard let s = String(data: data.prefix(500), encoding: .utf8) else { return "<non-utf8 data>" }
            return s
        }()
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let ctx):
                logger.event("decode failure: keyNotFound key='\(key.stringValue)' path=\(ctx.codingPath.map(\.stringValue).joined(separator: ".")) — \(ctx.debugDescription)")
            case .typeMismatch(let type, let ctx):
                logger.event("decode failure: typeMismatch expected=\(type) path=\(ctx.codingPath.map(\.stringValue).joined(separator: ".")) — \(ctx.debugDescription)")
            case .valueNotFound(let type, let ctx):
                logger.event("decode failure: valueNotFound type=\(type) path=\(ctx.codingPath.map(\.stringValue).joined(separator: ".")) — \(ctx.debugDescription)")
            case .dataCorrupted(let ctx):
                logger.event("decode failure: dataCorrupted path=\(ctx.codingPath.map(\.stringValue).joined(separator: ".")) — \(ctx.debugDescription)")
            @unknown default:
                logger.event("decode failure: \(decodingError)")
            }
        } else {
            logger.event("decode failure: \(error.localizedDescription)")
        }
        logger.event("response preview: \(preview)")
    }
}
