# Bidscube SDK for iOS

iOS SDK for image, video, and native ads. This repository now contains:

- the core iOS SDK pod/package: `BidscubeSDK`
- the Unity LevelPlay custom adapter pod: `LevelPlayMediationBidscubeAdapter`

## Requirements

- iOS 14.0+ and tvOS 14.0+ for `BidscubeSDK`
- `BidscubeSDK` 1.0.2
- `LevelPlayMediationBidscubeAdapter` 1.0.2 when using LevelPlay on iOS
- `IronSourceSDK` 9.3.0.0 when using LevelPlay (iOS only; the pod has no tvOS slice)
- Xcode 12+
- For LevelPlay mediation: Bidscube `placementId` configured as the custom adapter instance parameter

## Add the SDK

### CocoaPods

Assuming your project already uses CocoaPods, add:

```ruby
platform :ios, '14.0'
use_frameworks!

target 'YourApp' do
  pod 'BidscubeSDK', '1.0.2'
end
```

Then run:

```bash
pod install
```

### Swift Package Manager

```swift
.package(url: "https://github.com/BidsCube/LevelPlay-SDK-iOS.git", from: "1.0.2")
```

## Unity LevelPlay integration

See **`docs/LEVELPLAY_MEDIATION.md`** and **`RELEASE_STATUS.md`**.

### Dashboard setup

### 1. Add dependencies

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'BidscubeSDK', '1.0.2'
  pod 'IronSourceSDK', '9.3.0.0'
  pod 'LevelPlayMediationBidscubeAdapter', :git => 'https://github.com/BidsCube/LevelPlay-SDK-iOS.git', :tag => 'v1.0.2'
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

- Banner: adapter calls `BidscubeSDK.getImageAdView(...)` once on load and passes the returned `UIView` to LevelPlay.
- Interstitial: `loadAd` checks init and `placementId` only (no SSP request). Show calls `BidscubeSDK.presentImageAd(...)`.
- Rewarded: same load check. Show calls `BidscubeSDK.presentVideoAd(...)`. Reward is reported only after video completion.
- Native: **not supported** for LevelPlay custom adapter in this release.

Fullscreen ready state is per adapter instance. A no-fill is reported from show.

The adapter initializes `BidscubeSDK` on first use if it is not already initialized. That config uses `defaultAdPosition = .fullScreen` and a `userId` from `ISBidscubeCustomAdapter.setUserId` or the instance keys `userId` / `user_id`. If the app already called `BidscubeSDK.initialize`, the adapter does not override it; update the id afterwards with `BidscubeSDK.setUserId`.

### Apple TV

`BidscubeSDK` links on tvOS 14+. Ad views take Siri Remote focus, Select opens the click URL, and Menu closes a fullscreen ad. The request user agent identifies Apple TV. tvOS has no WebKit and no Google IMA, so HTML and VAST creatives fail closed; a direct image URL or mp4/m3u8 still plays. SKAdNetwork stays on iOS.

LevelPlay itself does not run on Apple TV. `IronSourceSDK` 9.3.0.0 (and 9.8.0.0) publishes an iOS slice only, so `LevelPlayMediationBidscubeAdapter` stays an iOS pod.

## Release status

See **`RELEASE_STATUS.md`**. OpenRTB 2.6 response parsing: **not implemented**.

## Local build

From the project root:

```bash
swift build
```

`swift build` compiles **BidscubeSDK** and the **LevelPlayMediationBidscubeAdapter** target. IronSource is **not** a SwiftPM dependency, so `ISBidscubeCustom*` types are only built when `canImport(IronSource)` is true (typically **CocoaPods** with `IronSourceSDK`). The manifest file **`LevelPlayMediationBidscubeAdapterManifest.swift`** always compiles and documents version **1.0.2** and integration notes.

For LevelPlay adapter distribution to apps, use **`LevelPlayMediationBidscubeAdapter.podspec`** (depends on `BidscubeSDK`, `IronSourceSDK`).

### LevelPlay adapter source layout (`Sources/LevelPlayMediationBidscubeAdapter`)

| File | Role |
|------|------|
| `LevelPlayMediationBidscubeAdapterManifest.swift` | `adapterVersion` (**1.0.2**), `placementInstanceKey`, CocoaPods IronSource floor, SPM note |
| `BidscubeLevelPlayAdapterPlacement.swift` | `bidscubePlacementId(from:)` and `userId` / `user_id` |
| `BidscubeLevelPlayAdapterDelegateInvoke.swift` | Optional rewarded delegate selectors |
| `BidscubeLevelPlayAdapterCallbacks.swift` | `AdCallback` implementations for banner load and fullscreen show |
| `ISBidscubeCustomAdapter.swift` | Base network adapter; `setUserId`; `networkSDKVersion` → `Constants.sdkVersion` |
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

Bidscube iOS SDK 1.0.2.
