# flutter_ci_cli

[![Pub Version](https://img.shields.io/pub/v/flutter_ci_cli.svg)](https://pub.dev/packages/flutter_ci_cli)
[![CI](https://github.com/DevPatel1479/flutter_ci_cli/actions/workflows/ci.yml/badge.svg)](https://github.com/DevPatel1479/flutter_ci_cli/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Bootstrap a reliable GitHub Actions CI workflow for Flutter projects in one command — interactive wizard or scriptable flags.  
Designed for Flutter 3.x and 4.x projects (Dart SDK `>=2.18.0 <4.0.0`).

---

## 🚀 What is `flutter_ci_cli`?

`flutter_ci_cli` is a small, focused command-line tool that auto-generates a GitHub Actions workflow for Flutter projects.  
It removes repetitive YAML authoring, offers optional auto-commit to your repo, and supports configuring analyze/test/build steps and platform signing options.

**Key benefits**
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

- Dart SDK: `>=2.18.0 <4.0.0` (covers Flutter 3.x and Flutter 4.x)
- Runs on: Windows, macOS, Linux (CLI)
- Generated workflow targets GitHub Actions (ubuntu/macOS runners)

---

## 📦 Install

**From pub.dev (recommended):**

```bash
dart pub global activate flutter_ci_cli
