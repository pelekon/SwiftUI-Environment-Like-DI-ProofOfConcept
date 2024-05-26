#
# Be sure to run `pod lib lint AdsSwiftUIUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'DependencyInjection'
    s.version          = '0.0.1'
    s.summary          = 'Test'
    s.description      = "Test"
  
    s.homepage         = 'https://github.com/pelekon/SwiftUI-Environment-Like-DI-ProofOfConcept'
    s.license          = { :type => 'MIT' }
    s.author           = { 'Bartłomiej Bukowiecki' => 'pelekon@gmail.com' }
    s.source           = { :git => 'https://github.com/pelekon/SwiftUI-Environment-Like-DI-ProofOfConcept.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '14.0'
    s.swift_version = '5.5'
    s.module_name = "DependencyInjection"
  
    s.source_files = 'Sources/DependencyInjection/**/*'
    s.preserve_paths = ["Package.swift", "Sources/DependencyInjectionMacros", 'macro_plugin_build.sh']

    macro_name="DependencyInjectionMacros"
    macro_product_path="$(PODS_BUILD_DIR)/Macros/#{macro_name}/release/#{macro_name}"
    plugin_path = "#{macro_product_path}##{macro_name}"
    files_for_input = ["Package.swift", "Sources/DependencyInjectionMacros/**/*.swift", "macro_plugin_build.sh"]

    new_config = {
        'OTHER_SWIFT_FLAGS' => "-Xfrontend -load-plugin-executable -Xfrontend #{plugin_path}",
        "DI_MACRO_BUILD_ENV" => 'DI_MACRO_COCOAPODS_BUILD=true'
    }

    s.user_target_xcconfig = new_config
    s.pod_target_xcconfig = new_config

    macro_build_script = <<-SCRIPT
        env -i PATH="$PATH" SRCROOT="$PODS_TARGET_SRCROOT" BUILD_DIR="$PODS_BUILD_DIR" TOOLCHAIN="$DT_TOOLCHAIN_DIR" $DI_MACRO_BUILD_ENV "${PODS_TARGET_SRCROOT}/macro_plugin_build.sh"
    SCRIPT

    s.script_phase = {
        :name  => "Build #{s.name} macro plugin",
        :script => macro_build_script,
        :input_files => Dir.glob(files_for_input).map {
            |path| "$(PODS_TARGET_SRCROOT)/#{path}"
        },
        :output_files => [macro_product_path],
        :execution_position => :before_compile
    }
end