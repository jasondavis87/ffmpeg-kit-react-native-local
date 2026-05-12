# FFmpegKit for React Native (Bundled Frameworks)

> **Fork Notice:** This is a modified fork of [jdarshan5/ffmpeg-kit-react-native](https://github.com/jdarshan5/ffmpeg-kit-react-native), which itself wraps [arthenica/ffmpeg-kit](https://github.com/arthenica/ffmpeg-kit). Full credit to the original authors.

> **Maintenance Notice:** This fork was created for one specific app and is **not maintained for general use**. The bundled binaries are configured for that app's exact feature set — see the "Bundled Frameworks" section below for what is and isn't enabled. Issues and PRs are unlikely to receive a response. Use at your own discretion or fork it for your own configuration.

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

This package ships pre-built FFmpeg frameworks compiled from [`jasondavis87/ffmpeg-kit-16KB`](https://github.com/jasondavis87/ffmpeg-kit-16KB) (a fork of [`AliAkhgar/ffmpeg-kit-16KB`](https://github.com/AliAkhgar/ffmpeg-kit-16KB) with modern-toolchain compatibility patches — Xcode 26 / iPhoneOS 26.4 SDK, CMake 4.x, recent Homebrew gettext).

**iOS** (`ios/Frameworks/`) — built for `arm64`, `x86-64`, `arm64-mac-catalyst`, `x86-64-mac-catalyst`, `arm64-simulator`:

- ffmpegkit.xcframework
- libavcodec.xcframework
- libavfilter.xcframework
- libavformat.xcframework
- libavutil.xcframework
- libavdevice.xcframework
- libswresample.xcframework
- libswscale.xcframework

**Android** (`android/libs/`) — built for `arm-v7a`, `arm-v7a-neon`, `arm64-v8a`, `x86`, `x86-64`:

- `ffmpeg-kit.aar` (~51 MB), 16KB page size compatible (NDK r25).

The bundle is LGPL-compliant. No GPL codecs are linked in.

### Linked external libraries

| Library | Why it's in |
|---|---|
| **libass** (+ freetype, fribidi, fontconfig, harfbuzz, expat, libpng via cascade) | `subtitles` filter and `drawtext` filter |
| **libzimg** | `zscale` filter — proper HDR→SDR tone mapping (BT.2020 ↔ BT.709 color/transfer conversion) |
| **openh264** | Software H.264 fallback for devices where hardware H.264 (MediaCodec / VideoToolbox) fails |

Hardware video decode/encode comes from the platforms themselves: **MediaCodec** on Android, **VideoToolbox** + **AudioToolbox** on iOS. Standard FFmpeg built-in filters (`vignette`, `gblur`, `overlay`, geometric/color transforms, etc.) are available without any external lib.

### Embedded `ffmpeg` configure flags

```
--enable-libass        --enable-libfontconfig  --enable-libfreetype
--enable-libfribidi    --enable-libopenh264    --enable-libzimg
--enable-iconv         --enable-mediacodec     --enable-videotoolbox
--enable-audiotoolbox  --enable-zlib
```

### Intentionally NOT included

To keep the binaries small and LGPL-only, the following are deliberately excluded. If your app needs them, fork this repo and rebuild from `jasondavis87/ffmpeg-kit-16KB` with the appropriate `--enable-*` flags:

- **TLS** (openssl, gnutls) — `https://` URLs are not passed directly to ffmpeg in this app; networking is handled outside ffmpeg and local file paths are passed in.
- **Audio codecs** (lame, opus, libvorbis, soxr) — not used by the consuming app.
- **Software video codecs** (libvpx VP8/VP9, dav1d AV1, libaom) — hardware codecs cover this app's needs.
- **Image-format decoders for the `overlay` filter** (libwebp, jpeg, tiff, giflib) — overlays in this app are pre-encoded as PNG, which FFmpeg decodes natively.
- **GPL libs** (x264, x265, xvidcore, libvidstab, rubberband) — license incompatibility.

## Requirements

- **iOS:** 13.0+
- **Android:** API Level 24+ (Android 7.0+)
- **Expo:** SDK 54+ with EAS Build
- **React Native:** 0.70+

---

## Rebuilding the frameworks

The binaries shipped here are produced from [`jasondavis87/ffmpeg-kit-16KB`](https://github.com/jasondavis87/ffmpeg-kit-16KB). That fork carries the toolchain-compat patches needed to build on a current macOS dev box (libpng v1.6.58 for `<fp.h>` removal under iPhoneOS 26 SDK, `CMAKE_POLICY_VERSION_MINIMUM=3.5` exported in `ios.sh` / `android.sh` for CMake 4.x compat, an Android-x86 openssl guard fix). See that repo's README for the exact list of customizations and macOS prereqs (`groff` etc.).

### Prerequisites

- Android Studio with SDK installed
- **NDK r25 with 16KB page-size support** — must come from `ci.android.com`, NOT the standard SDK Manager. See [`jasondavis87/ffmpeg-kit-16KB`](https://github.com/jasondavis87/ffmpeg-kit-16KB) for the URL. Do not "upgrade" to NDK r27/r28 — the upstream FFmpeg build chain doesn't support them.
- Java 17
- Xcode (any version with a working iPhoneOS SDK; the fork is currently building under Xcode 26 / iPhoneOS 26.4 SDK)

### iOS

```bash
./ios.sh -x \
  --enable-ios-videotoolbox \
  --enable-ios-audiotoolbox \
  --enable-ios-zlib \
  --disable-arm64e \
  --enable-libass \
  --enable-openh264 \
  --enable-zimg
```

### Android

```bash
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_NDK_ROOT=$HOME/Library/Android/sdk/ndk/25.2.9519653

./android.sh \
  --enable-android-media-codec \
  --enable-android-zlib \
  --enable-libass \
  --enable-openh264 \
  --enable-zimg
```

### Drop the outputs back into this repo

```bash
# from inside the ffmpeg-kit-16KB checkout, with this repo at $RN:
rm -rf $RN/ios/Frameworks/*.xcframework
cp -R prebuilt/bundle-apple-xcframework-ios/*.xcframework $RN/ios/Frameworks/
cp prebuilt/bundle-android-aar/ffmpeg-kit/ffmpeg-kit.aar $RN/android/libs/ffmpeg-kit.aar
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
