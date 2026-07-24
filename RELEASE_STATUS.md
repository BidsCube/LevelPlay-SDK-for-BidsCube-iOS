# Release status (LevelPlay — iOS)

**LevelPlay iOS:** supported for **Banner**, **Interstitial** (static/image), and **Rewarded** via CocoaPods `LevelPlayMediationBidscubeAdapter`.

**Integration:** use **CocoaPods** with `IronSourceSDK` + `LevelPlayMediationBidscubeAdapter`. SwiftPM alone does not link IronSource; `ISBidscubeCustom*` types require `canImport(IronSource)`.

**OpenRTB 2.6:** not implemented yet (response-side parsing belongs in `BidscubeSDK`; adapter does not POST bid requests).

**Native LevelPlay:** not supported in this release.

**Load/show:** availability precheck on load; render may occur again on show until preload/cache APIs ship in `BidscubeSDK`.

**Presenter:** `showAd(with: UIViewController, ...)` receives a presenter; BidscubeSDK does not expose presenter-aware show APIs on iOS yet.
