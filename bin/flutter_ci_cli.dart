import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_ci_cli/workflow_generator.dart';

const cliVersion = '1.0.1';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('version', abbr: 'v', negatable: false, help: 'Show CLI version')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addOption('repo', abbr: 'r', help: 'GitHub repository URL')
    ..addOption(
      'branch',
      abbr: 'b',
      defaultsTo: 'main',
      help: 'Branch to run CI/CD on',
    )
    ..addFlag(
      'android-sign',
      defaultsTo: false,
      negatable: true,
      help: 'Enable Android signing',
    )
    ..addFlag(
      'ios-sign',
      defaultsTo: false,
      negatable: true,
      help: 'Enable iOS signing',
    )
    ..addFlag(
      'analyze',
      defaultsTo: true,
      negatable: true,
      help: 'Include Flutter analyze step',
    )
    ..addFlag(
      'test',
      defaultsTo: true,
      negatable: true,
      help: 'Include Flutter test step',
    )
    ..addFlag(
      'build-android',
      defaultsTo: true,
      negatable: true,
      help: 'Include Android build',
    )
    ..addFlag(
      'build-ios',
      defaultsTo: false,
      negatable: true,
      help: 'Include iOS build',
    )
    ..addFlag(
      'auto-commit',
      defaultsTo: false,
      negatable: true,
      help: 'Commit workflow automatically to GitHub',
    );

  ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('❌ Invalid argument: $e');
    print(parser.usage);
    exit(1);
  }

  // Handle help/version
  if (args['help'] == true) {
    print('Flutter CI/CD CLI - Version $cliVersion\n');
    print(parser.usage);
    exit(0);
  }
  if (args['version'] == true) {
    print('flutter_ci_cli version: $cliVersion');
    exit(0);
  }

  print('🚀 Flutter CI/CD Auto-Setup CLI');

  // Step 1: Check Flutter project
  final currentDir = Directory.current;
  final pubspecFile = File(p.join(currentDir.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    print('❌ No Flutter project found in current directory.');
    exit(1);
  }

  // Step 2: Gather info (interactive if missing)
  final repoUrl =
      args['repo'] ?? _prompt('Enter your GitHub repository URL (HTTPS):');
  if (!repoUrl.startsWith('https://github.com/')) {
    print('❌ Invalid GitHub URL.');
    exit(1);
  }
  final branch = args['branch'] ?? 'main';

  final autoCommit = args['auto-commit'] == true;
  String? pat;
  if (autoCommit) {
    pat = _prompt(
      'Enter your GitHub Personal Access Token (hidden):',
      hidden: true,
    );
    if (pat.isEmpty) {
      print('❌ PAT required for auto commit');
      exit(1);
    }
  }

  // Android signing
  bool androidSign = args['android-sign'] ?? false;
  String? keystorePath, keyAlias, keystorePassword, keyPassword;
  if (androidSign) {
    keystorePath = _prompt('Enter path to your keystore file:');
    keyAlias = _prompt('Enter key alias:');
    keystorePassword = _prompt('Enter keystore password:');
    keyPassword = _prompt('Enter key password:');
    if (![
      keystorePath,
      keyAlias,
      keystorePassword,
      keyPassword,
    ].every((e) => e.isNotEmpty)) {
      print('❌ Android signing info incomplete');
      exit(1);
    }
  }

  // iOS signing
  bool iosSign = args['ios-sign'] ?? false;
  String? p12Path, profilePath, p12Password;
  if (iosSign) {
    p12Path = _prompt('Enter path to your .p12 certificate:');
    profilePath = _prompt('Enter path to provisioning profile:');
    p12Password = _prompt('Enter certificate password:');
    if (![
      p12Path,
      profilePath,
      p12Password,
    ].every((e) => e.isNotEmpty)) {
      print('❌ iOS signing info incomplete');
      exit(1);
    }
  }

  // Steps
  final analyze = args['analyze'] ?? true;
  final testStep = args['test'] ?? true;
  final buildAndroid = args['build-android'] ?? true;
  final buildIOS = args['build-ios'] ?? false;

  // Step 3: Generate workflow
  final workflowFilePath = '.github/workflows/flutter-ci.yml';
  if (File(workflowFilePath).existsSync()) {
    final overwrite = _prompt(
      'Workflow file already exists. Overwrite? (Y/n):',
    ).toLowerCase();
    if (overwrite != 'y') {
      print('Aborted by user.');
      exit(0);
    }
  }

  await generateWorkflow(
    branch: branch,
    analyze: analyze,
    test: testStep,
    buildAndroid: buildAndroid,
    buildIOS: buildIOS,
    androidSign: androidSign,
    iosSign: iosSign,
    keystorePath: keystorePath,
    keyAlias: keyAlias,
    keystorePassword: keystorePassword,
    keyPassword: keyPassword,
    p12Path: p12Path,
    profilePath: profilePath,
    p12Password: p12Password,
  );

  // Commit workflow
  if (autoCommit && pat != null) {
    print('Committing workflow to GitHub...');
    await commitWorkflowToGitHub(repoUrl, pat, branch);
  }

  print('✅ CI/CD workflow setup completed!');
}

/// Helper for interactive prompts
String _prompt(String message, {bool hidden = false}) {
  stdout.write('$message ');
  if (hidden) {
    stdin.echoMode = false;
    stdin.lineMode = true;
  }
  final input = stdin.readLineSync() ?? '';
  if (hidden) stdin.echoMode = true;
  return input.trim();
}
