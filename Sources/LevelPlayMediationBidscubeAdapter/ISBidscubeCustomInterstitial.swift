#if canImport(IronSource)
import Foundation
import UIKit
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomInterstitial)
public final class ISBidscubeCustomInterstitial: ISBaseInterstitial {
    private var showCallback: BidscubeInterstitialShowCallback?

    public override func loadAd(with adData: ISAdData, delegate: ISInterstitialAdDelegate) {
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToLoadWith(.internal, errorCode: ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }

        let callback = BidscubeInterstitialLoadCallback()
        callback.delegate = delegate
        _ = BidscubeSDK.getImageAdView(placementId, callback)
    }

    public override func isAdAvailable(with adData: ISAdData) -> Bool {
        guard let placementId = bidscubePlacementId(from: adData) else { return false }
        return BidscubeLevelPlayAdapterState.isInterstitialLoaded(placementId)
    }

    public override func showAd(with viewController: UIViewController, adData: ISAdData, delegate: ISInterstitialAdDelegate) {
        // Presenter-aware show APIs are not exposed by BidscubeSDK on iOS yet; viewController is reserved.
        _ = viewController
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToShowWithErrorCode(ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }

        guard BidscubeLevelPlayAdapterState.isInterstitialLoaded(placementId) else {
            delegate.adDidFailToShowWithErrorCode(ISAdapterErrorInternal, errorMessage: "Interstitial ad is not ready")
            return
        }

        let callback = BidscubeInterstitialShowCallback()
        callback.delegate = delegate
        showCallback = callback
        BidscubeSDK.showImageAd(placementId, callback)
    }
}
#endif
