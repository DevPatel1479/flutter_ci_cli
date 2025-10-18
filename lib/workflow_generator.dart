import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

Future<void> generateWorkflow({
  required String branch,
  required bool analyze,
  required bool test,
  required bool buildAndroid,
  required bool buildIOS,
  required bool androidSign,
  required bool iosSign,
  String? keystorePath,
  String? keyAlias,
  String? keystorePassword,
  String? keyPassword,
  String? p12Path,
  String? profilePath,
  String? p12Password,
}) async {
  final workflowDir = Directory('.github/workflows');
  if (!workflowDir.existsSync()) workflowDir.createSync(recursive: true);

  final workflowFile = File(p.join(workflowDir.path, 'flutter-ci.yml'));
  if (workflowFile.existsSync()) {
    stdout.write('Workflow file exists. Overwrite? (Y/n): ');
    final overwrite = stdin.readLineSync()?.toLowerCase() ?? 'n';
    if (overwrite != 'y') {
      print('Aborted. Workflow not overwritten.');
      return;
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('name: Flutter CI');
  buffer.writeln('on:');
  buffer.writeln('  push:');
  buffer.writeln('    branches:');
  buffer.writeln('      - $branch');
  buffer.writeln('  pull_request:');
  buffer.writeln('    branches:');
  buffer.writeln('      - $branch');
  buffer.writeln('jobs:');
  buffer.writeln('  build:');
  buffer.writeln('    runs-on: ubuntu-latest');
  buffer.writeln('    steps:');
  buffer.writeln('      - uses: actions/checkout@v3');
  buffer.writeln('      - name: Setup Flutter');
  buffer.writeln('        uses: subosito/flutter-action@v2');
  buffer.writeln('        with:');
  buffer.writeln('          flutter-version: stable');
  buffer.writeln('      - name: Install dependencies');
  buffer.writeln('        run: flutter pub get');

  if (analyze) {
    buffer.writeln('      - name: Analyze\n        run: flutter analyze');
  }
  if (test) {
    buffer.writeln('      - name: Run tests\n        run: flutter test');
  }

  if (buildAndroid) {
    buffer.writeln('      - name: Build APK');
    if (androidSign && keystorePath != null) {
      buffer.writeln(
        '        run: flutter build apk --release --flavor prod --dart-define=KEYSTORE=$keystorePath',
      );
    } else {
      buffer.writeln('        run: flutter build apk --release');
    }
  }

  if (buildIOS) {
    buffer.writeln('      - name: Build iOS');
    buffer.writeln('        if: runner.os == "macOS"'); // Only macOS runner
    buffer.writeln('        run: flutter build ios --release');
  }

  workflowFile.writeAsStringSync(buffer.toString());
  print('✅ Workflow file created at ${workflowFile.path}');
}

Future<void> commitWorkflowToGitHub(
  String repoUrl,
  String pat,
  String branch,
) async {
  try {
    final uriParts = repoUrl.replaceAll('https://github.com/', '').split('/');
    if (uriParts.length != 2) {
      print('❌ Invalid GitHub repository URL.');
      return;
    }
    final owner = uriParts[0];
    final repo = uriParts[1];

    final filePath = '.github/workflows/flutter-ci.yml';
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ Workflow file not found at $filePath');
      return;
    }

    final content = base64Encode(await file.readAsBytes());
    final apiUrl =
        'https://api.github.com/repos/$owner/$repo/contents/$filePath';

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'token $pat',
        'Accept': 'application/vnd.github+json',
      },
      body: jsonEncode({
        'message': 'Add Flutter CI/CD workflow',
        'content': content,
        'branch': branch,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Workflow committed to GitHub successfully.');
    } else {
      print('❌ Failed to commit workflow: ${response.body}');
    }
  } catch (e) {
    print('❌ Error committing workflow: $e');
  }
}
