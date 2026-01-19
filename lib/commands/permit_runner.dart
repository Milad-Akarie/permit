import 'package:args/command_runner.dart';
import 'package:permit/path/path_finder.dart';

/// Main command runner for the Permit CLI.
class PermitRunner extends CommandRunner {
  /// The path finder used to locate project files.
  final PathFinder pathFinder;

  /// Default constructor.
  PermitRunner(this.pathFinder) : super('permit', 'A CLI tool to manage native app permissions');
}

/// Abstract base class for all Permit commands.
abstract class PermitCommand extends Command {
  /// Default constructor.
  PermitCommand();

  /// Accessor for the [PathFinder] from the [PermitRunner].
  /// Throws [StateError] if the runner is not a [PermitRunner].
  PathFinder get pathFinder {
    if (runner is PermitRunner) {
      return (runner as PermitRunner).pathFinder;
    }
    throw StateError('Runner is not a PermitRunner');
  }
}
