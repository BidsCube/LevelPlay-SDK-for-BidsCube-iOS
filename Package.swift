// swift-tools-version:6.0
// This package is iOS-only and requires iOS 13.0+
import PackageDescription
import Foundation

/// GitHub Actions: Google's IMA SPM binary ZIP often fails to extract (NSCocoaErrorDomain 513). CI sets
/// `BIDSCUBE_SPM_SKIP_IMA=1` so `swift package resolve` never downloads it. Normal consumers leave this unset.
private let skipGoogleIMA = ProcessInfo.processInfo.environment["BIDSCUBE_SPM_SKIP_IMA"] == "1"

private let googleIMAPackage = Package.Dependency.package(
    url: "https://github.com/googleads/swift-package-manager-google-interactive-media-ads-ios.git",
    from: "3.19.0"
)

let package = Package(
    name: "BidscubeSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BidscubeSDK",
            targets: ["BidscubeSDK"]
        ),
        .library(
            name: "LevelPlayMediationBidscubeAdapter",
            targets: ["LevelPlayMediationBidscubeAdapter"]
        ),
    ],
    dependencies: skipGoogleIMA ? [] : [googleIMAPackage],
    targets: [
        .target(
            name: "BidscubeSDK",
            dependencies: skipGoogleIMA
                ? []
                : [
                    .product(
                        name: "GoogleInteractiveMediaAds",
                        package: "swift-package-manager-google-interactive-media-ads-ios"
                    ),
                ],
            path: "Sources/BidscubeSDK",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .define("SWIFT_PACKAGE"),
                .define("TARGET_OS_IPHONE", to: "1"),
                .define("TARGET_OS_IOS", to: "1"),
            ],
            swiftSettings: skipGoogleIMA
                ? [
                    .define("TARGET_OS_IPHONE"),
                    .define("TARGET_OS_IOS"),
                    .define("BIDSCUBE_NO_IMA"),
                ]
                : [
                    .define("TARGET_OS_IPHONE"),
                    .define("TARGET_OS_IOS"),
                ]
        ),
        // LevelPlay IronSource adapters: compiled only when `canImport(IronSource)` (CocoaPods / Xcode with IronSource).
        // SwiftPM alone ships `LevelPlayMediationBidscubeAdapterManifest` + empty `#if` stubs; ISBidscubeCustom* require IronSource.
        .target(
            name: "LevelPlayMediationBidscubeAdapter",
            dependencies: ["BidscubeSDK"],
            path: "Sources/LevelPlayMediationBidscubeAdapter",
            swiftSettings: [
                .define("TARGET_OS_IPHONE"),
                .define("TARGET_OS_IOS")
            ]
        ),
        .testTarget(
            name: "bidscubeSdkTests",
            dependencies: ["BidscubeSDK"],
            path: "Tests/bidscubeSdkTests"
        )
    ],
    swiftLanguageModes: [.v6]
)
