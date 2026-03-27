Pod::Spec.new do |s|
  s.name             = 'dart_freetype'
  s.version          = '1.1.0'
  s.summary          = 'FreeType binding for Dart/Flutter (FFI)'
  s.description      = <<-DESC
Builds and bundles a vendored copy of FreeType for use via Dart FFI.
DESC
  s.homepage         = 'https://github.com/klsruan/dart_freetype'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Open Source' => 'opensource@example.com' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '12.0'
  s.static_framework = true
  s.requires_arc = false

  s.source_files = [
    '../src/dart_freetype.c',
    '../src/freetype_wrapper.c',
    '../src/freetype/src/**/*.{c,h}',
  ]

  s.preserve_paths = [
    '../src/freetype/include/**/*',
  ]

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_C_LANGUAGE_STANDARD' => 'c11',
    'GCC_PREPROCESSOR_DEFINITIONS' => 'FT2_BUILD_LIBRARY=1',
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/../src/freetype/include"',
  }
end

