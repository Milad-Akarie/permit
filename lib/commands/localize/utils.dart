// This only validates basic language code formats.
// it does not check against a full list of valid codes.
bool isValidLanguageCode(String code) {
  // Matches:
  // - en, ar, fr (2-letter)
  // - eng, ara (3-letter)
  // - en-US, pt-BR (with region)
  // - zh-Hans, zh-Hant (with script)
  return RegExp(r'^[a-z]{2,3}(-[A-Z][a-z]{3})?(-[A-Z]{2})?$').hasMatch(code);
}
