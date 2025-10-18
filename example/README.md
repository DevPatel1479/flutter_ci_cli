# Flutter CI/CD CLI

🚀 **Bootstrap a reliable GitHub Actions CI workflow for Flutter projects in one command** — interactive wizard or scriptable flags.  
Designed for Flutter 3.x and 4.x projects (Dart SDK >=2.18.0 <4.0.0).

---

## 🧐 What is `flutter_ci_cli`?

`flutter_ci_cli` is a small, focused command-line tool that auto-generates a GitHub Actions workflow for Flutter projects.  
It removes repetitive YAML authoring, offers optional auto-commit to your repo, and supports configuring analyze/test/build steps and platform signing options.

**Key benefits:**

- One-command workflow generation  
- Interactive prompts or fully scriptable via command-line flags  
- Safe defaults (iOS build conditional on macOS runner)  
- Helps teams standardize CI across many projects  

---

## 🔧 Features

- Interactive wizard to generate `.github/workflows/flutter-ci.yml`  
- Argument-based (non-interactive) mode for automation  
- Optional Android & iOS build steps  
- Optional auto-commit to GitHub (requires PAT)  
- Avoids embedding secrets directly in YAML — supports GitHub Secrets workflow  
- Works on Windows, macOS, and Linux  

---

## 🔁 Supported SDKs & Platforms

- **Dart SDK:** >=2.18.0 <4.0.0 (covers Flutter 3.x and Flutter 4.x)  
- **Runs on:** Windows, macOS, Linux (CLI)  
- **Generated workflow:** GitHub Actions (ubuntu/macOS runners)  

---

## 📦 Installation

From pub.dev (recommended):

```bash
dart pub global activate flutter_ci_cli

```



Assume your Flutter project is located at my_flutter_project.

## 1️⃣ Run the CLI interactively

cd my_flutter_project
flutter_ci_cli --repo https://github.com/username/my_flutter_project


## Interactive prompts & example user inputs:

🚀 Flutter CI/CD Auto-Setup CLI
✅ Flutter project detected. Enable CI/CD? (Y/n): y
Enter your GitHub repository URL (HTTPS): https://github.com/username/my_flutter_project
Enter the branch to run CI/CD on (default: main): main
Do you want to enable Android signing? (y/N): y
Enter path to your keystore file: android/app/my-release-key.jks
Enter key alias: my-key-alias
Enter keystore password: ********
Enter key password: ********
Do you want to enable iOS signing? (y/N): n
Workflow file already exists. Overwrite? (Y/n): y
✅ Workflow file created at .github/workflows/flutter-ci.yml
Do you want to commit the workflow automatically to GitHub? (y/N): n
✅ CI/CD workflow setup completed!



## 2️⃣ Run CLI non-interactively (using flags)

flutter_ci_cli \
  --repo https://github.com/username/my_flutter_project \
  --branch main \
  --android-sign \
  --no-ios-sign \
  --no-test \
  --auto-commit


This command will:

Generate the .github/workflows/flutter-ci.yml workflow file

Skip iOS signing

Skip Flutter tests

Auto-commit workflow to GitHub (requires a Personal Access Token)

## 3️⃣ Result

After running, your project will have a ready-to-use GitHub Actions workflow:

my_flutter_project/
└─ .github/
   └─ workflows/
      └─ flutter-ci.yml

Push your Flutter project to GitHub, and the workflow will automatically trigger CI/CD runs on the specified branch.


## ⚡ CLI Options

-v, --version               Show CLI version
-h, --help                  Show this help
-r, --repo                  GitHub repository URL
-b, --branch                Branch to run CI/CD on (defaults to "main")
--[no-]android-sign     Enable Android signing
--[no-]ios-sign         Enable iOS signing
--[no-]analyze          Include Flutter analyze step (defaults to on)
--[no-]test             Include Flutter test step (defaults to on)
--[no-]build-android    Include Android build (defaults to on)
--[no-]build-ios        Include iOS build
--[no-]auto-commit      Commit workflow automatically to GitHub

