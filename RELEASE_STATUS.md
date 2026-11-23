# Release status (LevelPlay — iOS)

**LevelPlay iOS:** supported for **Banner**, **Interstitial** (static/image), and **Rewarded** via CocoaPods `LevelPlayMediationBidscubeAdapter`.

**Integration:** use **CocoaPods** with `IronSourceSDK` + `LevelPlayMediationBidscubeAdapter`. SwiftPM alone does not link IronSource; `ISBidscubeCustom*` types require `canImport(IronSource)`.

**OpenRTB 2.6:** not implemented yet (response-side parsing belongs in `BidscubeSDK`; adapter does not POST bid requests).

**Apple TV:** `BidscubeSDK` supports tvOS. LevelPlay does not — `IronSourceSDK` has no tvOS slice.

**Load/show:** banner loads once via `getImageAdView`. Interstitial and rewarded load only mark the instance ready; show is the single SSP request (`presentImageAd` / `presentVideoAd`).

**Presenter:** fullscreen show uses the `UIViewController` passed by LevelPlay.
