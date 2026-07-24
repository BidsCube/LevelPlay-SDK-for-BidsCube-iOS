#if canImport(IronSource)
import Foundation
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomAdapter)
public final class ISBidscubeCustomAdapter: ISBaseNetworkAdapter {
    public override func `init`(_ adData: ISAdData, delegate: ISNetworkInitializationDelegate) {
        _ = BidscubeLevelPlayServerParams.from(adData)
        if !BidscubeSDK.isInitialized() {
            NSLog("BidscubeLevelPlay: initializing BidscubeSDK from adapter fallback config.")
            BidscubeSDK.initialize()
        }
        if BidscubeSDK.isInitialized() {
            delegate.onInitDidSucceed()
        } else {
            delegate.onInitDidFailWith(.internal, errorCode: ISAdapterErrorInternal, errorMessage: "BidscubeSDK initialization failed")
        }
    }

    public override func networkSDKVersion() -> String {
        Constants.sdkVersion
    }

    public override func adapterVersion() -> String {
        LevelPlayMediationBidscubeAdapterManifest.adapterVersion
    }
}
#endif
