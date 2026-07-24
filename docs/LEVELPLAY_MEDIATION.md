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

## Formats

- **Interstitial:** static/image (`getImageAdView` / `showImageAd`) — this release
- **Rewarded:** video
- **Native LevelPlay:** not supported

## Load/show (temporary bridge)

Load performs availability precheck; show may trigger another Bidscube request until preload/cache APIs exist.

## OpenRTB 2.6

Not implemented. Adapter does not POST OpenRTB bid requests.

## Clean archive

```bash
git archive --format=zip --output ../LevelPlay-SDK-iOS-release.zip HEAD
```
