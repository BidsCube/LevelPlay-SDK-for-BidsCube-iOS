# LevelPlay (IronSource) mediation — native iOS

## Flow

```text
LevelPlay / IronSource
    ↓
ISBidscubeCustom* adapters (CocoaPods)
    ↓
BidscubeSDK
```

## Integration

Use **CocoaPods** — `LevelPlayMediationBidscubeAdapter.podspec` + `IronSourceSDK`. SwiftPM ships manifest/stubs only; production custom-network integration requires IronSource linked at build time.

## Dashboard classes

| Role | Class |
|------|-------|
| Base | `ISBidscubeCustomAdapter` |
| Banner | `ISBidscubeCustomBanner` |
| Interstitial | `ISBidscubeCustomInterstitial` |
| Rewarded | `ISBidscubeCustomRewardedVideo` |

**Instance:** `placementId`

**Optional instance keys**

| Key | Applied |
|-----|---------|
| `userId` / `user_id` | `SDKConfig.userId` only when this adapter calls `BidscubeSDK.initialize` |
| `request_authority`, `ssp_host`, `stats_authority` | Parsed and ignored. The SDK keeps its built-in SSP endpoint |
| pod keys (`openrtb_pod_metadata_enabled`, `video_pod_*`) | Parsed and ignored. This iOS SDK has no pod config |

Host apps can set the publisher id before LevelPlay init:

```swift
ISBidscubeCustomAdapter.setUserId("USER_ID")
```

An empty string clears the pending id. The call is ignored once `BidscubeSDK.initialize` has completed. After init, use `BidscubeSDK.setUserId`. Consent (`gdpr`, `us_privacy`, `coppa`) is read from IAB `UserDefaults` on each ad request and is not an adapter config field.

## Formats

| Format | Load | Show |
|--------|------|------|
| Banner | One `getImageAdView`. LevelPlay receives that `UIView` | LevelPlay displays the view |
| Interstitial | Checks init and `placementId`, marks this adapter instance ready, `adDidLoad`. No SSP request | One `presentImageAd` from the LevelPlay view controller |
| Rewarded | Same ready check, no SSP request | One `presentVideoAd`. `adRewarded` only after `onVideoAdCompleted` without a skip or early close |

**Native LevelPlay:** not supported.

LevelPlay can select this network before a real fill exists. A no-fill or playback error is reported from **show**. Ready state is per adapter instance.

## Apple TV

`BidscubeSDK` supports tvOS 14+: focus, Select for clicks, Menu to close fullscreen, and an Apple TV user agent. tvOS has no WebKit, so HTML creatives fail closed and a direct image or mp4/m3u8 plays instead. IMA/VAST stays on iOS. `IronSourceSDK` does not ship a tvOS binary (`platforms.ios` only), so this LevelPlay adapter cannot be linked into an Apple TV target. Use `BidscubeSDK` directly on tvOS.

## OpenRTB 2.6

Not implemented. Adapter does not POST OpenRTB bid requests.

## Clean archive

```bash
git archive --format=zip --output ../LevelPlay-SDK-iOS-release.zip HEAD
```
