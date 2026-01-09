require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# Path to local FFmpeg frameworks (relative to this podspec)
ffmpeg_ios_dir = File.join(__dir__, '..', '..', 'ffmpeg', 'ios')

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

  # Local FFmpeg frameworks from consuming app's ffmpeg/ios/ directory
  s.vendored_frameworks = Dir[File.join(ffmpeg_ios_dir, '*.xcframework')]

  # System frameworks required by FFmpeg
  s.frameworks = 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'VideoToolbox'

  # System libraries required by FFmpeg
  s.libraries = 'z', 'bz2', 'iconv', 'c++'

  # Header search paths for FFmpeg headers inside xcframeworks
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => [
      "#{ffmpeg_ios_dir}/ffmpegkit.xcframework/ios-arm64/ffmpegkit.framework/Headers",
      "#{ffmpeg_ios_dir}/libavcodec.xcframework/ios-arm64/libavcodec.framework/Headers",
      "#{ffmpeg_ios_dir}/libavformat.xcframework/ios-arm64/libavformat.framework/Headers",
      "#{ffmpeg_ios_dir}/libavutil.xcframework/ios-arm64/libavutil.framework/Headers",
      "#{ffmpeg_ios_dir}/libavfilter.xcframework/ios-arm64/libavfilter.framework/Headers",
      "#{ffmpeg_ios_dir}/libavdevice.xcframework/ios-arm64/libavdevice.framework/Headers",
      "#{ffmpeg_ios_dir}/libswresample.xcframework/ios-arm64/libswresample.framework/Headers",
      "#{ffmpeg_ios_dir}/libswscale.xcframework/ios-arm64/libswscale.framework/Headers"
    ].join(' ')
  }
end
