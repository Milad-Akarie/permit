import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:permit/commands/add_permission_command.dart';
import 'package:permit/commands/delete_permission_command.dart';
import 'package:permit/commands/list_permissions_command.dart';
import 'package:permit/commands/permit_runner.dart';
import 'package:permit/path/path_finder.dart';
import 'package:permit/utils/logger.dart';

Future<void> main(List<String> args) async {
  final projectDir = PathFinder.findRootDirectory(Directory.current);
  if (projectDir == null) {
    Logger.error('Could not find project root. Please run this command from within a Flutter project.');
    exit(1);
  }
  final runner = PermitRunner(PathFinderImpl(projectDir))
    ..addCommand(AddPermissionCommand())
    ..addCommand(DeletePermissionCommand())
    ..addCommand(ListPermissionsCommand());
  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(e);
  }
}
