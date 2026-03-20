#if canImport(IronSource)
import Foundation
import UIKit
import IronSource
import BidscubeSDK

@objc(ISBidscubeCustomRewardedVideo)
public final class ISBidscubeCustomRewardedVideo: ISBaseRewardedVideo {
    private var showCallback: BidscubeRewardedShowCallback?

    public override func loadAd(with adData: ISAdData, delegate: ISRewardedVideoAdDelegate) {
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToLoadWith(.internal, errorCode: ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }

        let callback = BidscubeRewardedLoadCallback()
        callback.delegate = delegate
        _ = BidscubeSDK.getVideoAdView(placementId, callback)
    }

    public override func isAdAvailable(with adData: ISAdData) -> Bool {
        guard let placementId = bidscubePlacementId(from: adData) else { return false }
        return BidscubeLevelPlayAdapterState.loadedRewardedPlacements.contains(placementId)
    }

    public override func showAd(with viewController: UIViewController, adData: ISAdData, delegate: ISRewardedVideoAdDelegate) {
        _ = viewController
        guard let placementId = bidscubePlacementId(from: adData) else {
            delegate.adDidFailToShowWithErrorCode(ISAdapterErrorMissingParams, errorMessage: "Missing placementId")
            return
        }

        guard BidscubeLevelPlayAdapterState.loadedRewardedPlacements.contains(placementId) else {
            delegate.adDidFailToShowWithErrorCode(ISAdapterErrorInternal, errorMessage: "Rewarded ad is not ready")
            return
        }

        let callback = BidscubeRewardedShowCallback()
        callback.delegate = delegate
        showCallback = callback
        BidscubeSDK.showVideoAd(placementId, callback)
    }
}
#endif
