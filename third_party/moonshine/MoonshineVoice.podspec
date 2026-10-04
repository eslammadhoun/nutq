Pod::Spec.new do |s|
  s.name             = 'MoonshineVoice'
  s.version          = '0.1.5'
  s.summary          = 'Moonshine on-device speech recognition (vendored xcframework).'
  s.description      = <<-DESC
Moonshine Voice C library, vendored as a prebuilt xcframework so the app can
transcribe Arabic on device with no network call. The framework is not
committed; run fetch-framework.sh to download it.
                       DESC
  s.homepage         = 'https://github.com/moonshine-ai/moonshine'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Moonshine AI' => 'https://moonshine.ai' }
  s.source           = { :path => '.' }

  s.ios.deployment_target = '15.6'
  s.osx.deployment_target = '13.0'

  # The xcframework holds a static library plus the C API headers, so the
  # module is imported in Swift as `import Moonshine`.
  s.vendored_frameworks = 'Moonshine.xcframework'
  s.libraries           = 'c++'
  s.static_framework    = true
end
