# FFmpegKit for React Native (Bundled Frameworks)

> **Fork Notice:** This is a modified fork of [jdarshan5/ffmpeg-kit-react-native](https://github.com/jdarshan5/ffmpeg-kit-react-native), which itself wraps [arthenica/ffmpeg-kit](https://github.com/arthenica/ffmpeg-kit). Full credit to the original authors.

> **Maintenance Notice:** This fork was created for a specific project and is not actively maintained. It bundles pre-built FFmpeg frameworks directly in the package for reliable Expo/EAS builds. Use at your own discretion.

## Installation

Add to your `package.json`:

```json
{
  "dependencies": {
    "ffmpeg-kit-react-native": "github:jasondavis87/ffmpeg-kit-react-native-local"
  }
}
```

Then install:

```bash
# Using bun (recommended)
bun install

# Using npm
npm install

# Using yarn
yarn install
```

For iOS, run `pod install` in your ios directory:

```bash
cd ios && pod install && cd ..
```

**Note:** The Android AAR file is not stored in Git LFS, so initial install may take longer as it downloads the full file. LFS caused issues with Android builds.

## Bundled Frameworks

This package includes pre-built FFmpeg frameworks:

**iOS** (`ios/Frameworks/`):
- ffmpegkit.xcframework
- libavcodec.xcframework
- libavformat.xcframework
- libavutil.xcframework
- libavfilter.xcframework
- libavdevice.xcframework
- libswresample.xcframework
- libswscale.xcframework

**Android** (`android/libs/`):
- ffmpeg-kit.aar (compiled with 16KB page size support using NDK r25 from [AliAkhgar/ffmpeg-kit-16KB](https://github.com/AliAkhgar/ffmpeg-kit-16KB))

The frameworks are LGPL-compliant, built with hardware acceleration (VideoToolbox on iOS, MediaCodec on Android), without GPL codecs.

## Requirements

- **iOS:** 13.0+
- **Android:** API Level 24+ (Android 7.0+)
- **Expo:** SDK 54+ with EAS Build
- **React Native:** 0.70+

---

## Building Frameworks (For Reference)

If you need to rebuild the frameworks:
- **iOS:** Use [arthenica/ffmpeg-kit](https://github.com/arthenica/ffmpeg-kit)
- **Android (16KB page size):** Use [AliAkhgar/ffmpeg-kit-16KB](https://github.com/AliAkhgar/ffmpeg-kit-16KB)

### Prerequisites

- Android Studio with SDK installed
- NDK r25 with 16KB page size support (see [AliAkhgar/ffmpeg-kit-16KB](https://github.com/AliAkhgar/ffmpeg-kit-16KB) for download links)
- Java 17
- Xcode (for iOS)

### Android Build (16KB page size)

```bash
ANDROID_NDK_ROOT=$HOME/Library/Android/sdk/ndk/25.2.9519653 \
CMAKE_POLICY_VERSION_MINIMUM=3.5 \
./android.sh --enable-android-media-codec --enable-android-zlib
```

### iOS Build

```bash
./ios.sh -x --enable-ios-videotoolbox --enable-ios-audiotoolbox --enable-ios-zlib --disable-arm64e
```

---

## Usage

```js
import { FFmpegKit, ReturnCode } from 'ffmpeg-kit-react-native-local';

FFmpegKit.execute('-i file1.mp4 -c:v mpeg4 file2.mp4').then(async (session) => {
  const returnCode = await session.getReturnCode();

  if (ReturnCode.isSuccess(returnCode)) {
    // SUCCESS
  } else if (ReturnCode.isCancel(returnCode)) {
    // CANCEL
  } else {
    // ERROR
  }
});
```

### More Examples

See the [original documentation](https://github.com/arthenica/ffmpeg-kit/wiki/React-Native) for:
- Async execution with callbacks
- FFprobe commands
- Media information extraction
- Session management
- Storage Access Framework (Android)

## License

See [License](https://github.com/arthenica/ffmpeg-kit/wiki/License) wiki page.

## Credits

- [arthenica/ffmpeg-kit](https://github.com/arthenica/ffmpeg-kit) - The underlying FFmpeg kit
- [jdarshan5/ffmpeg-kit-react-native](https://github.com/jdarshan5/ffmpeg-kit-react-native) - React Native wrapper this fork is based on
