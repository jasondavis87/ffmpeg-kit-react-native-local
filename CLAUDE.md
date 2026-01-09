# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fork of ffmpeg-kit-react-native with **bundled FFmpeg frameworks** via Git LFS. Unlike the original which uses CocoaPods/Maven, this package includes pre-built xcframeworks and AAR files directly, making it work reliably with Expo/EAS builds.

## Repository

https://github.com/jasondavis87/ffmpeg-kit-react-native-local

## Common Commands

```bash
# Run tests
yarn test

# Run linting
yarn lint
```

## Architecture

### Bundled Frameworks

```
ios/Frameworks/           # iOS xcframeworks (Git LFS)
  ├── ffmpegkit.xcframework/
  ├── libavcodec.xcframework/
  └── ...

android/libs/             # Android AAR (Git LFS)
  └── ffmpeg-kit.aar
```

### Native Bridge

- **`ios/FFmpegKitReactNativeModule.{h,m}`** - Objective-C bridge to FFmpegKit
- **`android/src/main/java/`** - Java bridge to FFmpegKit

### JavaScript Layer

- **`src/index.js`** - Main JS implementation with NativeEventEmitter callbacks
- **`src/index.d.ts`** - TypeScript definitions

## iOS Configuration (Podspec)

Key settings in `ffmpeg-kit-react-native.podspec`:
- `vendored_frameworks = 'ios/Frameworks/*.xcframework'`
- Uses `$(PODS_TARGET_SRCROOT)` for header search paths (reliable in EAS)
- System frameworks: AudioToolbox, AVFoundation, CoreMedia, VideoToolbox
- System libraries: z, bz2, iconv

## Android Configuration (build.gradle)

Key settings in `android/build.gradle`:
- Uses `files("$projectDir/libs/ffmpeg-kit.aar")` for local AAR
- Requires `api 'com.arthenica:smart-exception-java:0.2.1'` (transitive dependency)
- Uses `api` scope so classes are available to consuming app at runtime

## Platform Requirements

- **iOS:** 13.0+
- **Android:** API 24+ (Android 7.0+)
- **Expo:** SDK 54+ with EAS Build

## Key Differences from Original

1. Frameworks bundled in package (no external downloads needed)
2. No CocoaPods subspecs or Maven package variants
3. Uses direct file paths instead of dependency resolution
4. Transitive dependencies must be explicitly declared
