/// Utility extensions for String and double types.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Converts the string to camelCase.
  String toCamelCase() {
    final words = split(RegExp(r'[_\s-]+'));
    if (words.isEmpty) return this;
    final firstWord = words.first.toLowerCase();
    final capitalizedWords = words.skip(1).map((word) => word.capitalize());
    return [firstWord, ...capitalizedWords].join();
  }

  /// Converts the string to PascalCase.
  String toPascalCase() {
    final words = split(RegExp(r'[_\s-]+'));
    final capitalizedWords = words.map((word) => word.capitalize());
    return capitalizedWords.join();
  }
}

/// Utility extension for double type.
extension DoubleExt on double {
  /// Converts the double to a string, omitting decimal places if it's an integer.
  String toShortString() {
    if (this % 1 == 0) {
      return toInt().toString();
    } else {
      return toString();
    }
  }
}
