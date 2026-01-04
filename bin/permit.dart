import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:permit/commands/add_permission_command.dart';
import 'package:permit/commands/delete_permission_command.dart';
import 'package:permit/commands/list_permissions_command.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:permit/path/path_finder.dart';

Future<void> main(List<String> args) async {
  final runner = PermitRunner(PathFinderImpl(Directory.current))
    ..addCommand(AddPermissionCommand())
    ..addCommand(DeletePermissionCommand())
    ..addCommand(ListPermissionsCommand());
  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
  }
}
