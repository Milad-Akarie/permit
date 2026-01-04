import 'package:args/command_runner.dart';
import 'package:permit/path/path_finder.dart';

class PermitRunner extends CommandRunner {
  final PathFinder pathFinder;
  PermitRunner(this.pathFinder) : super('permit', 'A CLI tool to manage native app permissions');
}

abstract class PermitCommand extends Command {
  PathFinder get pathFinder {
    if (runner is PermitRunner) {
      return (runner as PermitRunner).pathFinder;
    }
    throw StateError('Runner is not a PermitRunner');
  }
}
