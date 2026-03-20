#if canImport(IronSource)
import Foundation
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomAdapter)
public final class ISBidscubeCustomAdapter: ISBaseNetworkAdapter {
    public override func `init`(_ adData: ISAdData, delegate: ISNetworkInitializationDelegate) {
        _ = adData
        if !BidscubeSDK.isInitialized() {
            BidscubeSDK.initialize()
        }
        delegate.onInitDidSucceed()
    }

    public override func networkSDKVersion() -> String {
        Constants.sdkVersion
    }

    public override func adapterVersion() -> String {
        LevelPlayMediationBidscubeAdapterManifest.adapterVersion
    }
}
#endif
