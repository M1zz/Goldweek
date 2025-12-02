//
//  Logger.swift
//  LeaveWise
//
//  앱 전반 로깅 시스템
//

import Foundation
import os.log

// MARK: - 로그 카테고리
enum LogCategory: String {
    case app = "App"
    case data = "Data"
    case iCloud = "iCloud"
    case backup = "Backup"
    case widget = "Widget"
    case recommendation = "Recommendation"
    case ui = "UI"
}

// MARK: - 로그 레벨
enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }

    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

// MARK: - 앱 로거
final class AppLogger {
    static let shared = AppLogger()

    private let subsystem = Bundle.main.bundleIdentifier ?? "com.Ysoup.LeaveWise"
    private var loggers: [LogCategory: Logger] = [:]

    private init() {
        // 각 카테고리별 Logger 초기화
        for category in [LogCategory.app, .data, .iCloud, .backup, .widget, .recommendation, .ui] {
            loggers[category] = Logger(subsystem: subsystem, category: category.rawValue)
        }
    }

    // MARK: - 로깅 메서드
    func log(_ message: String, level: LogLevel = .info, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.emoji) [\(level.rawValue)] [\(category.rawValue)] \(fileName):\(line) \(function) - \(message)"

        // Console 출력 (Debug 빌드에서만)
        #if DEBUG
        print(logMessage)
        #endif

        // os.log 출력
        if let logger = loggers[category] {
            switch level {
            case .debug:
                logger.debug("\(message)")
            case .info:
                logger.info("\(message)")
            case .warning:
                logger.warning("\(message)")
            case .error:
                logger.error("\(message)")
            }
        }
    }

    // MARK: - 편의 메서드
    func debug(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }

    func info(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }

    func warning(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }

    func error(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }

    // MARK: - 에러 로깅
    func logError(_ error: Error, message: String? = nil, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        let errorMessage = message ?? "Error occurred"
        log("\(errorMessage): \(error.localizedDescription)", level: .error, category: category, file: file, function: function, line: line)
    }
}

// MARK: - 전역 로깅 함수
func logDebug(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
    AppLogger.shared.debug(message, category: category, file: file, function: function, line: line)
}

func logInfo(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
    AppLogger.shared.info(message, category: category, file: file, function: function, line: line)
}

func logWarning(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
    AppLogger.shared.warning(message, category: category, file: file, function: function, line: line)
}

func logError(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
    AppLogger.shared.error(message, category: category, file: file, function: function, line: line)
}

func logError(_ error: Error, message: String? = nil, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
    AppLogger.shared.logError(error, message: message, category: category, file: file, function: function, line: line)
}
