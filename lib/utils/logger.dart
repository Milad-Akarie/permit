import 'package:ansicolor/ansicolor.dart' show AnsiPen;

/// A static logging utility for the lean_builder package.
///
/// Provides different logging levels with color-coded output and
/// optional stack trace information. Uses a singleton pattern to
/// ensure consistent logging throughout the application.
class Logger {
  static final Logger _instance = Logger._internal();

  /// Factory constructor that returns the singleton instance.
  factory Logger() {
    return _instance;
  }

  /// Private constructor for singleton pattern.
  Logger._internal();

  /// Current logging level. Messages below this level won't be displayed.
  static LogLevel _currentLevel = LogLevel.info;

  /// Sets the minimum logging level.
  ///
  /// Messages with a level lower than this will not be displayed.
  static set level(LogLevel newLevel) {
    _currentLevel = newLevel;
  }

  /// Logs a message at the specified level if it meets the current threshold.
  ///
  /// @param level The severity level of the message
  /// @param message The text to be logged
  void log(LogLevel level, String message) {
    if (level.index >= _currentLevel.index) {
      final AnsiPen pen = _getLevelPen(level);
      print('${pen('[${level.name.toUpperCase()}]')} $message');
    }
  }

  /// Logs a fine-level message (lowest priority).
  ///
  /// Use for very detailed tracing information.
  static void fine(String message) {
    _instance.log(LogLevel.fine, message);
  }

  /// Logs an informational message.
  ///
  /// Use for general information about application progress.
  static void info(String message) {
    _instance.log(LogLevel.info, message);
  }

  /// Logs a warning message.
  ///
  /// Use for potential issues that don't prevent the application from working.
  static void warning(String message) {
    _instance.log(LogLevel.warning, message);
  }

  /// Logs an error message, optionally with a stack trace.
  ///
  /// Use for errors that affect functionality but don't crash the application.
  /// When a stack trace is provided, it will be formatted and included in the output.
  ///
  /// @param message The error message to log
  /// @param stackTrace Optional stack trace to include with the error
  static void error(String message) {
    _instance.log(LogLevel.error, message);
  }

  /// Logs a debug message.
  ///
  /// Use for information useful for debugging but not needed in normal operation.
  static void debug(String message) {
    _instance.log(LogLevel.debug, message);
  }

  /// Logs a success message.
  ///
  /// Use to indicate successful completion of an operation.
  static void success(String message) {
    _instance.log(LogLevel.success, message);
  }

  /// Returns the appropriate color pen for the given log level.
  ///
  /// @param level The log level to get a color for
  /// @return An AnsiPen configured with the appropriate color
  AnsiPen _getLevelPen(LogLevel level) {
    switch (level) {
      case LogLevel.fine:
        return AnsiPen()..white(bold: true);
      case LogLevel.success:
        return AnsiPen()..rgb(r: 0.11, g: 0.69, b: 0.38);
      case LogLevel.debug:
        return AnsiPen()..rgb(r: 0.463, g: 0.557, b: 0.6);
      case LogLevel.info:
        return AnsiPen()..rgb(r: 0.067, g: 0.612, b: 0.6);
      case LogLevel.warning:
        return AnsiPen()..rgb(r: 0.612, g: 0.439, b: 0.067);
      case LogLevel.error:
        return AnsiPen()..rgb(r: 0.678, g: 0.216, b: 0.216);
    }
  }
}

/// Log severity levels in ascending order of importance.
///
/// - fine: Very detailed tracing information
/// - debug: Debugging information
/// - info: General information (default level)
/// - success: Operation completed successfully
/// - warning: Potential issues that don't prevent operation
/// - error: Errors that affect functionality
enum LogLevel {
  /// Very detailed tracing information
  fine,

  /// Debugging information
  debug,

  /// General information (default level)
  info,

  /// Operation completed successfully
  success,

  /// Potential issues that don't prevent operation
  warning,

  /// Errors that affect functionality
  error,
}
