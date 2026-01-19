import 'package:permit/commands/permit_runner.dart';
import 'package:permit/generate/plugin_generator.dart';

/// Command to synchronize permissions metadata and regenerate the plugin code.
///
/// Usage: `permit build`
///
/// This command will read both info.plist and AndroidManifest.xml and check
/// for permission declarations annotated with `<!--@permit:code ... -->` comments.
///  It will then regenerate the plugin code to ensure that the permissions
///  are correctly declared in the generated code.
class BuildCodeCommand extends PermitCommand {
  /// Default constructor.
  BuildCodeCommand();

  @override
  String get description =>
      'Synchronize permissions metadata and generated code';

  @override
  String get name => 'build';

  @override
  Future<void> run() async {
    // Generate plugin code
    PluginGenerator(pathFinder: pathFinder).generate();
  }
}
