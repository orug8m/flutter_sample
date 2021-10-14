# flutter_sample

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setting

for Mac OS

```
$ brew install flutter
# XCode for iOS

# Android Studio for Android
$ brew install android-sdk # sdkmanagerコマンドを使うために入れる

$ touch ~/.android/repositories.cfg # これをしておくと以下回避できる
# Warning: File /Users/helloworld/.android/repositories.cfg could not be loaded.
# Warning: Failed to find package sdkmanager

$ sdkmanager sdkmanager --install "cmdline-tools;latest"

# AVD(Android 仮想Device（Emulator）)をセットアップ
# Android Studio上でポチポチする
# https://developer.android.com/studio/run/managing-avds#viewing

$ flutter doctor
# => Good when all green
```
