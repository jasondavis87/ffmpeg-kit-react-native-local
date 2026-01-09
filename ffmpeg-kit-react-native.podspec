require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# FFmpeg frameworks location relative to $(SRCROOT) (the iOS project directory)
# Structure: apps/native/ios/ <- $(SRCROOT)
#            apps/native/ffmpeg/ios/*.xcframework <- frameworks
# So from $(SRCROOT): ../ffmpeg/ios/
ffmpeg_frameworks_path = '$(SRCROOT)/../ffmpeg/ios'

Pod::Spec.new do |s|
  s.name         = package["name"]
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platform                  = :ios, '13.0'
  s.ios.deployment_target     = '13.0'
  s.requires_arc              = true
  s.static_framework          = true

  s.source = { :http => "https://github.com/jdarshan5/ffmpeg-kit-react-native.git" }

  s.dependency "React-Core"

  s.source_files = 'ios/**/*.{h,m}'

  # System frameworks required by FFmpeg
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'VideoToolbox'

  # System libraries required by FFmpeg
  s.libraries = 'z', 'bz2', 'iconv', 'c++'

  # Xcode build settings for local FFmpeg frameworks
  # Uses $(SRCROOT) which resolves at build time to the iOS project directory
  s.pod_target_xcconfig = {
    # Where to find the xcframeworks
    'FRAMEWORK_SEARCH_PATHS' => "\"#{ffmpeg_frameworks_path}\"",

    # Header search paths for #import <ffmpegkit/...> style imports
    # The framework Headers folder is the parent, so imports like <ffmpegkit/FFmpegKitConfig.h> work
    'HEADER_SEARCH_PATHS' => [
      "\"#{ffmpeg_frameworks_path}/ffmpegkit.xcframework/ios-arm64/ffmpegkit.framework/Headers\"",
      "\"#{ffmpeg_frameworks_path}/ffmpegkit.xcframework/ios-arm64_x86_64-simulator/ffmpegkit.framework/Headers\""
    ].join(' '),

    # Link the FFmpeg frameworks
    'OTHER_LDFLAGS' => [
      '-framework ffmpegkit',
      '-framework libavcodec',
      '-framework libavformat',
      '-framework libavutil',
      '-framework libavfilter',
      '-framework libavdevice',
      '-framework libswresample',
      '-framework libswscale'
    ].join(' ')
  }

  # User project also needs to know where frameworks are
  s.user_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => "\"#{ffmpeg_frameworks_path}\""
  }

  # Script to validate frameworks exist at build time
  s.script_phase = {
    :name => 'Validate FFmpeg Frameworks',
    :script => <<-SCRIPT
      FFMPEG_DIR="${SRCROOT}/../ffmpeg/ios"
      if [ ! -d "$FFMPEG_DIR/ffmpegkit.xcframework" ]; then
        echo "error: FFmpeg frameworks not found at $FFMPEG_DIR"
        echo "error: Please ensure xcframeworks are placed in your app's ffmpeg/ios/ directory"
        exit 1
      fi
    SCRIPT
  }
end
