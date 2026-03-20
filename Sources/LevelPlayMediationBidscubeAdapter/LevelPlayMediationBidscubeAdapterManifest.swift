import Foundation

/// Single source for LevelPlay custom adapter versioning (align with `BidscubeSDK.Constants.sdkVersion` and Android `ADAPTER_VERSION`).
public enum LevelPlayMediationBidscubeAdapterManifest {
    public static let adapterVersion = "1.0.0"
    /// Documented CocoaPods floor for `IronSourceSDK` when using this adapter (see `LevelPlayMediationBidscubeAdapter.podspec`).
    public static let minimumIronSourceCocoaPodsVersion = "9.3.0.0"
    public static let placementInstanceKey = "placementId"

    /// SwiftPM builds this package without IronSource; full `ISBidscubeCustom*` types exist only when IronSource is linked (CocoaPods).
    public static let integrationNote =
        "ISBidscubeCustomAdapter, Banner, Interstitial, and Rewarded require CocoaPods: IronSourceSDK + LevelPlayMediationBidscubeAdapter."
}
