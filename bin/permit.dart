import 'package:args/command_runner.dart';
import 'package:permit/commands/add_permission_command.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner('permit', 'A small permission helper')..addCommand(AddPermissionCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
  }
}
