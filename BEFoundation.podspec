Pod::Spec.new do |s|

# Common settings
  s.name         = "BEFoundation"
  s.version      = "1.1.1"
  s.summary      = "Objective-C extensions to Foundation: notifications, runtime, numbers, data, images, and collections."
  s.description  = <<-DESC
BEFoundation extends Apple's Foundation with priority notifications, dynamic methods and
other runtime manipulation, mutable numbers, data-URL and download handling, image and Metal
helpers, security-scoped bookmark management, file caching, path watching, and a set of
collection and string categories. It is cross-platform: AppKit and UIKit differences are
bridged by BEPlatformTypes.
                      DESC
  s.homepage     = "https://github.com/belisoful/BEFoundation"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "belisoful" => "belisoful@icloud.com" }
  s.source       = { :git => 'https://github.com/belisoful/BEFoundation.git', :tag => s.version.to_s }

# Platforms
  s.osx.deployment_target = "11.0"
  s.ios.deployment_target = "14.0"

# Build
  s.source_files        = 'Sources/BEFoundation/**/*.{h,hpp,m,mm}'
  s.public_header_files = 'Sources/BEFoundation/include/BEFoundation/*.h'
  s.exclude_files       = 'Sources/BEFoundation/BEFoundation.docc/**/*'
  s.requires_arc        = true
  s.frameworks          = 'Foundation', 'CoreImage', 'Metal', 'Accelerate'
  s.osx.frameworks      = 'AppKit'
  s.ios.frameworks      = 'UIKit'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++20',
    'CLANG_CXX_LIBRARY'           => 'libc++',
    'GCC_C_LANGUAGE_STANDARD'     => 'gnu17'
  }
end
