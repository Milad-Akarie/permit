import 'package:permit/commands/permit_runner.dart';
import 'package:permit/generate/plugin_generator.dart';

class SyncCodeCommand extends PermitCommand {
  @override
  String get description => 'Synchronize permissions metadata and generated code';

  @override
  String get name => 'sync';

  @override
  Future<void> run() async {
    // Generate plugin code
    PluginGenerator(pathFinder: pathFinder).generate();
  }
}
