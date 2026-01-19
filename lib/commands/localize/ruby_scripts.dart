import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:permit/utils/logger.dart';

/// Checks if the xcodeproj gem is installed.
Future<bool> isXcodeprojInstalled() async {
  try {
    final result = await Process.run('gem', ['list', '-i', 'xcodeproj']);
    return result.stdout.toString().trim() == 'true';
  } catch (e) {
    return false;
  }
}

/// Tries to install the xcodeproj gem.
Future<void> installXcodeproj() async {
  Logger.info('Trying to install xcodeproj gem...');

  final result = await Process.run('gem', ['install', 'xcodeproj']);

  if (result.exitCode != 0) {
    Logger.error('Failed to install xcodeproj.');
    Logger.error('Error: ${result.stderr}');
    Logger.info('Try running: sudo gem install xcodeproj');
    exit(1);
  }
  Logger.success('xcodeproj installed');
}

/// Gets the known regions and source language from the Xcode project.
Future<(String source, Set<String> regions)> getKnownRegions(
  String projectPath,
) async {
  final rubyScript =
      '''
require "xcodeproj"

project_path = "$projectPath"

begin
  project = Xcodeproj::Project.open(project_path)
  
  # Get development region (source language) - print it first
  dev_region = project.root_object.development_region
  puts dev_region
  
  # Get known regions
  known_regions = project.root_object.known_regions
  known_regions.each do |region|
    puts region
  end
rescue => e
  STDERR.puts "Error: " + e.message
  exit 1
end
''';

  final result = await Process.run('ruby', ['-e', rubyScript]);

  if (result.exitCode != 0) {
    Logger.error('Error getting known regions: ${result.stderr}');
    return ('en', <String>{});
  }

  // Parse output - first line is source language, rest are known regions
  final lines = result.stdout
      .toString()
      .trim()
      .split('\n')
      .where((line) => line.isNotEmpty)
      .map((line) => line.trim())
      .toList();

  if (lines.isEmpty) {
    return ('en', <String>{});
  }

  final source = lines.first;
  final regions = lines
      .skip(1) // Skip the first line (source language)
      .where(
        (region) => region != 'Base',
      ) // Filter out "Base" - not a real language
      .toSet();

  return (source, regions);
}

/// Adds a reference to the xcstrings file in the Xcode project.
Future<void> addXcodeReference({
  required String projectPath,
  required String xcstringsPath,
}) async {
  final fileName = p.basename(xcstringsPath);
  // Ruby script to add the file
  final rubyScript =
      '''
require "xcodeproj"

project_path = "$projectPath"
full_file_path = "$xcstringsPath"
file_name = "$fileName"

begin
  project = Xcodeproj::Project.open(project_path)
  target = project.targets.first

  # Check if file already exists (check by filename)
  existing = project.files.find { |f| f.path == file_name || f.path == full_file_path }

  if existing.nil?
    # Find or create the Runner group (where other app files live)
    runner_group = project.main_group.groups.find { |g| g.display_name == "Runner" }
    
    if runner_group.nil?
      # If no Runner group, use main group
      runner_group = project.main_group
    end
    
    # Add file reference to Runner group with just the filename
    # This makes it relative to the Runner group location
    file_ref = runner_group.new_reference(file_name)
    
    # Set the source tree to group-relative
    file_ref.source_tree = "<group>"
    
    # Add to resources build phase
    target.resources_build_phase.add_file_reference(file_ref)
    
    # Save
    project.save
    
  else
    puts "\\#{file_name} already exists in project"
  end
rescue => e
  puts "Error: \\#{e.message}"
  exit 1
end
''';

  // Run the Ruby script
  final result = await Process.run('ruby', ['-e', rubyScript]);

  if (result.exitCode != 0) {
    Logger.error('Error adding to Xcode project');
    Logger.error(result.stderr);
    exit(1);
  }
}
