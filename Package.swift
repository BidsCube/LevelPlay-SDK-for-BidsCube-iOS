// swift-tools-version:6.0
// iOS 14+ and tvOS 14+. Google IMA is linked on iOS only.
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
        .iOS(.v14),
        .tvOS(.v14)
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
                        package: "swift-package-manager-google-interactive-media-ads-ios",
                        condition: .when(platforms: [.iOS])
                    ),
                ],
            path: "Sources/BidscubeSDK",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .define("SWIFT_PACKAGE"),
                .define("TARGET_OS_IPHONE", to: "1", .when(platforms: [.iOS, .tvOS])),
                .define("TARGET_OS_IOS", to: "1", .when(platforms: [.iOS])),
            ],
            swiftSettings: skipGoogleIMA
                ? [
                    .define("TARGET_OS_IPHONE", .when(platforms: [.iOS, .tvOS])),
                    .define("TARGET_OS_IOS", .when(platforms: [.iOS])),
                    .define("BIDSCUBE_NO_IMA"),
                ]
                : [
                    .define("TARGET_OS_IPHONE", .when(platforms: [.iOS, .tvOS])),
                    .define("TARGET_OS_IOS", .when(platforms: [.iOS])),
                ]
        ),
        // LevelPlay IronSource adapters: compiled only when `canImport(IronSource)` (CocoaPods / Xcode with IronSource).
        // SwiftPM alone ships `LevelPlayMediationBidscubeAdapterManifest` + empty `#if` stubs; ISBidscubeCustom* require IronSource.
        .target(
            name: "LevelPlayMediationBidscubeAdapter",
            dependencies: ["BidscubeSDK"],
            path: "Sources/LevelPlayMediationBidscubeAdapter",
            swiftSettings: [
                .define("TARGET_OS_IPHONE", .when(platforms: [.iOS, .tvOS])),
                .define("TARGET_OS_IOS", .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "bidscubeSdkTests",
            dependencies: ["BidscubeSDK"],
            path: "Tests/bidscubeSdkTests"
        )
    ],
    // CocoaPods builds this pod as Swift 5.9. Swift 6 mode rejects the SDK's existing shared state.
    swiftLanguageModes: [.v5]
)
