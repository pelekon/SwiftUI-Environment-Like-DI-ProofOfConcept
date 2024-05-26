SDK=$(xcrun --show-sdk-path)
swift build --configuration release --product DependencyInjectionMacros --sdk "$SDK" --toolchain "$TOOLCHAIN" --package-path "$SRCROOT" --scratch-path "${BUILD_DIR}/Macros/DependencyInjectionMacros"