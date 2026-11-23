#if canImport(IronSource)
import Foundation
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomAdapter)
public final class ISBidscubeCustomAdapter: ISBaseNetworkAdapter {
    /// Applied only when this adapter is the one that calls `BidscubeSDK.initialize`.
    private static var pendingUserId: String?

    /// Publisher user id sent as `user_id` when this adapter initializes the SDK.
    /// Ignored if the host already called `BidscubeSDK.initialize`. After init, use `BidscubeSDK.setUserId`.
    @objc public static func setUserId(_ userId: String?) {
        if BidscubeSDK.isInitialized() {
            NSLog("BidscubeLevelPlay: setUserId ignored; BidscubeSDK is already initialized.")
            return
        }
        pendingUserId = normalizedUserId(userId)
    }

    public override func `init`(_ adData: ISAdData, delegate: ISNetworkInitializationDelegate) {
        let params = BidscubeLevelPlayServerParams.from(adData)
        if !BidscubeSDK.isInitialized() {
            let userId = params.userId ?? ISBidscubeCustomAdapter.pendingUserId
            NSLog("BidscubeLevelPlay: initializing BidscubeSDK from adapter config.")
            let config = SDKConfig.Builder()
                .enableLogging(false)
                .enableDebugMode(false)
                .defaultAdPosition(.fullScreen)
                .userId(userId)
                .build()
            BidscubeSDK.initialize(config: config)
        } else {
            NSLog("BidscubeLevelPlay: BidscubeSDK already initialized; LevelPlay will not override configuration.")
        }
        if BidscubeSDK.isInitialized() {
            delegate.onInitDidSucceed()
        } else {
            delegate.onInitDidFailWith(.internal, errorCode: ISAdapterErrorInternal, errorMessage: "BidscubeSDK initialization failed")
        }
    }

    private static func normalizedUserId(_ userId: String?) -> String? {
        let trimmed = userId?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let trimmed, !trimmed.isEmpty else { return nil }
        return trimmed
    }

    public override func networkSDKVersion() -> String {
        Constants.sdkVersion
    }

    public override func adapterVersion() -> String {
        LevelPlayMediationBidscubeAdapterManifest.adapterVersion
    }
}
#endif
