import 'package:args/command_runner.dart';
import 'package:permit/commands/add_permission_command.dart';
import 'package:permit/commands/delete_permission_command.dart';
import 'package:permit/commands/list_permissions_command.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner('permit', 'A small permission helper')
    ..addCommand(AddPermissionCommand())
    ..addCommand(DeletePermissionCommand())
    ..addCommand(ListPermissionsCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
  }
}
