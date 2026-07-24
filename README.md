# Bidscube SDK for iOS

iOS SDK for image, video, and native ads. This repository now contains:

- the core iOS SDK pod/package: `BidscubeSDK`
- the Unity LevelPlay custom adapter pod: `LevelPlayMediationBidscubeAdapter`

## Requirements

- iOS 13.0+
- `BidscubeSDK` 1.0.1
- `LevelPlayMediationBidscubeAdapter` 1.0.1 when using LevelPlay
- `IronSourceSDK` 9.3.0.0 when using LevelPlay
- Xcode 12+
- For LevelPlay mediation: Bidscube `placementId` configured as the custom adapter instance parameter

## Add the SDK

### CocoaPods

Assuming your project already uses CocoaPods, add:

```ruby
platform :ios, '14.0'
use_frameworks!

target 'YourApp' do
  pod 'BidscubeSDK', '1.0.1'
end
```

Then run:

```bash
pod install
```

### Swift Package Manager

```swift
.package(url: "https://github.com/BidsCube/LevelPlay-SDK-iOS.git", from: "1.0.1")
```

## Unity LevelPlay integration

See **`docs/LEVELPLAY_MEDIATION.md`** and **`RELEASE_STATUS.md`**.

### Dashboard setup

### 1. Add dependencies

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'BidscubeSDK', '1.0.1'
  pod 'IronSourceSDK', '9.3.0.0'
  pod 'LevelPlayMediationBidscubeAdapter', :git => 'https://github.com/BidsCube/LevelPlay-SDK-iOS.git', :tag => 'v1.0.1'
end
```

The adapter depends on `BidscubeSDK` and `IronSourceSDK`.

### 2. LevelPlay setup

- Base adapter class: `ISBidscubeCustomAdapter`
- Banner adapter class: `ISBidscubeCustomBanner`
- Interstitial adapter class: `ISBidscubeCustomInterstitial`
- Rewarded adapter class: `ISBidscubeCustomRewardedVideo`
- Instance parameter: `placementId`

### 3. LevelPlay format behavior

- Banner: adapter calls `BidscubeSDK.getImageAdView(...)` and passes the returned `UIView` to LevelPlay.
- Interstitial: adapter validates availability during `loadAd` and shows via `BidscubeSDK.showImageAd(...)`.
- Rewarded: adapter validates availability during `loadAd` and shows via `BidscubeSDK.showVideoAd(...)`.
- Native: **not supported** for LevelPlay custom adapter in this release.

Load performs an availability precheck; show may trigger another Bidscube request until preload/cache APIs exist in the native SDK.

The adapter initializes `BidscubeSDK` on first use if it is not already initialized (prefer app-level init with `SDKConfig`).

## Release status

See **`RELEASE_STATUS.md`**. OpenRTB 2.6 response parsing: **not implemented**.

## Local build

From the project root:

```bash
swift build
```

`swift build` compiles **BidscubeSDK** and the **LevelPlayMediationBidscubeAdapter** target. IronSource is **not** a SwiftPM dependency, so `ISBidscubeCustom*` types are only built when `canImport(IronSource)` is true (typically **CocoaPods** with `IronSourceSDK`). The manifest file **`LevelPlayMediationBidscubeAdapterManifest.swift`** always compiles and documents version **1.0.1** and integration notes.

For LevelPlay adapter distribution to apps, use **`LevelPlayMediationBidscubeAdapter.podspec`** (depends on `BidscubeSDK`, `IronSourceSDK`).

### LevelPlay adapter source layout (`Sources/LevelPlayMediationBidscubeAdapter`)

| File | Role |
|------|------|
| `LevelPlayMediationBidscubeAdapterManifest.swift` | `adapterVersion` (**1.0.1**), `placementInstanceKey`, CocoaPods IronSource floor, SPM note |
| `BidscubeLevelPlayAdapterState.swift` | Loaded interstitial / rewarded placement sets (Android parity) |
| `BidscubeLevelPlayAdapterPlacement.swift` | `bidscubePlacementId(from:)` |
| `BidscubeLevelPlayAdapterDelegateInvoke.swift` | Optional rewarded delegate selectors |
| `BidscubeLevelPlayAdapterCallbacks.swift` | `AdCallback` implementations + load `finished` guards |
| `ISBidscubeCustomAdapter.swift` | Base network adapter; `networkSDKVersion` → `Constants.sdkVersion` |
| `ISBidscubeCustomBanner.swift` | Banner |
| `ISBidscubeCustomInterstitial.swift` | Interstitial |
| `ISBidscubeCustomRewardedVideo.swift` | Rewarded |

Repository layout:

- `Sources/BidscubeSDK`
- `Sources/LevelPlayMediationBidscubeAdapter`
- `Tests/bidscubeSdkTests`
- `Examples/`

## SwiftPM / CI: IMA binary ZIP errors (Code=513)

The **GoogleInteractiveMediaAds** SPM dependency downloads a large binary ZIP. On **GitHub Actions macOS**, SwiftPM often fails with `NSCocoaErrorDomain Code=513` while cleaning its temp directory (even with `--disable-sandbox`).

**In CI**, **`BIDSCUBE_SPM_SKIP_IMA=1`** is set: `Package.swift` then **omits** Google IMA, and the build uses **`BIDSCUBE_NO_IMA`** with a stub `IMAVideoAdHandler` (enough for `resolve` / `describe`; **IMA video does not work** in that configuration).

**Normal integration** (Xcode / local machine without that env var) keeps IMA as before.

To reproduce CI locally:

```bash
BIDSCUBE_SPM_SKIP_IMA=1 swift package resolve
```

If you need to fetch IMA but hit 513 locally:

```bash
rm -rf .build
swift package --disable-sandbox --scratch-path /tmp/bidscube-spm resolve
```

## License

MIT. See `LICENSE`.

## Version

Bidscube iOS SDK 1.0.1.
