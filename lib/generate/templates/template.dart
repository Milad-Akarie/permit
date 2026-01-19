/// Template base class
/// This class defines the interface for code templates used in code generation.
abstract class Template {
  /// The file path where the generated template will be saved.
  String get path;

  /// Generates the content of the template as a string.
  String generate();

  /// Factory constructor to create a default template instance.
  const Template();
}
